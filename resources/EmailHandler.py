import os
import json
import base64
import re
import time
import urllib.request
import urllib.parse
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
from robot.api import logger
from robot.libraries.BuiltIn import BuiltIn  

class EmailHandler:
    def __init__(self):
        pass
    def _get_access_token(self):
        from robot.libraries.BuiltIn import BuiltIn
        
        # 1. Read and strictly clean the variables (removes hidden spaces and quotes)
        client_id = str(BuiltIn().get_variable_value("${GMAIL_CLIENT_ID}")).strip(' "')
        client_secret = str(BuiltIn().get_variable_value("${GMAIL_CLIENT_SECRET}")).strip(' "')
        refresh_token = str(BuiltIn().get_variable_value("${GMAIL_REFRESH_TOKEN}")).strip(' "')
        
        if not all([client_id, client_secret, refresh_token]) or client_id == "None":
            raise Exception("CRITICAL ERROR: Missing one or more OAuth variables in Copado UI!")
            
        # 2. Silently negotiate a fresh access token from Google
        data = urllib.parse.urlencode({
            'client_id': client_id,
            'client_secret': client_secret,
            'refresh_token': refresh_token,
            'grant_type': 'refresh_token'
        }).encode('utf-8')
        
        token_url = 'https://oauth2.googleapis.com/token'
        
        req = urllib.request.Request(token_url, data=data, method='POST')
        try:
            with urllib.request.urlopen(req) as response:
                resp_data = json.loads(response.read().decode())
                return resp_data['access_token']
        except urllib.error.HTTPError as e:
            # This will print the exact reason Google rejected it if it fails again
            error_body = e.read().decode()
            raise Exception(f"Failed to refresh OAuth token: {e.code} - {error_body}")

    def _make_api_call(self, url, token, method='GET', payload=None):
        headers = {
            'Authorization': f'Bearer {token}',
            'Content-Type': 'application/json'
        }
        data = json.dumps(payload).encode('utf-8') if payload else None
        req = urllib.request.Request(url, data=data, headers=headers, method=method)
        with urllib.request.urlopen(req) as response:
            return json.loads(response.read().decode())

    def send_gmail(self, sender, recipient, subject, body):
        token = self._get_access_token()
        
        sender = str(sender).replace('\xa0', ' ').strip()
        recipient = str(recipient).replace('\xa0', ' ').strip()
        subject = str(subject).replace('\xa0', ' ').strip()
        body = str(body).replace('\xa0', ' ').strip()

        msg = MIMEMultipart()
        msg['To'] = recipient
        msg['From'] = sender
        msg['Subject'] = subject
        msg.attach(MIMEText(body, 'html', 'utf-8'))

        raw_msg = base64.urlsafe_b64encode(msg.as_bytes()).decode('utf-8')
        
        url = 'https://gmail.googleapis.com/gmail/v1/users/me/messages/send'
        try:
            self._make_api_call(url, token, method='POST', payload={'raw': raw_msg})
            logger.info(f"Successfully sent email to {recipient} via Gmail API")
        except Exception as e:
            raise Exception(f"Failed to send email via API: {str(e)}")

    def verify_email_and_extract_urls(self, email_address, subject, partial_body, retries=5, delay=10):
        token = self._get_access_token()
        
        subject = str(subject).replace('\xa0', ' ').strip()
        partial_body = str(partial_body).replace('\xa0', ' ').strip()
        
        logger.info(f"DEBUG: Searching via API for Target Subject: '{subject}'")

        for attempt in range(retries):
            logger.info(f"DEBUG: --- Starting API Check Attempt {attempt + 1}/{retries} ---")
            try:

                query = urllib.parse.quote(f'subject:"{subject}"')
                search_url = f'https://gmail.googleapis.com/gmail/v1/users/me/messages?q={query}&maxResults=5'
                
                results = self._make_api_call(search_url, token)
                messages = results.get('messages', [])

                if not messages:
                    logger.info("DEBUG: No matching emails found yet.")
                    time.sleep(delay)
                    continue

                for msg_info in messages:
                    msg_id = msg_info['id']
                    msg_url = f'https://gmail.googleapis.com/gmail/v1/users/me/messages/{msg_id}?format=full'
                    msg_data = self._make_api_call(msg_url, token)
                    
                    payload = msg_data.get('payload', {})
                    body_data = ""
                    
                    if 'parts' in payload:
                        for part in payload['parts']:
                            if part['mimeType'] == 'text/html':
                                body_data = part['body'].get('data', '')
                                break
                            elif part['mimeType'] == 'multipart/alternative':
                                for subpart in part['parts']:
                                    if subpart['mimeType'] == 'text/html':
                                        body_data = subpart['body'].get('data', '')
                                        break
                    else:
                        body_data = payload['body'].get('data', '')

                    if not body_data:
                        continue

                    # Fix base64 padding and decode
                    pad = len(body_data) % 4
                    if pad:
                        body_data += '=' * (4 - pad)
                        
                    decoded_body = base64.urlsafe_b64decode(body_data).decode('utf-8', errors='ignore')
                    
                    if partial_body in decoded_body:
                        logger.info("DEBUG: => BODY MATCHED! Extracting URLs...")
                        urls = re.findall(r'href=["\'](https?://[^"\']+)["\']', decoded_body)
                        logger.info(f"DEBUG: Extracted URLs: {urls}")
                        return urls
                    else:
                        logger.info("DEBUG: Subject matched, but body snippet not found.")
                        
                time.sleep(delay)
                
            except Exception as e:
                logger.info(f"DEBUG: Error during API fetch: {str(e)}")
                time.sleep(delay)
                
        raise Exception(f"Could not find the email with subject '{subject}' after {retries} attempts.")