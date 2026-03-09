import smtplib
import imaplib
import email
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
import time
from robot.libraries.BuiltIn import BuiltIn  

class EmailHandler:
    
    def __init__(self):
        pass

    def send_gmail(self, sender, recipient, subject, body):
        password = BuiltIn().get_variable_value("${GMAIL_APP_PASSWORD}")
        if not password:
            raise Exception("CRITICAL ERROR: ${GMAIL_APP_PASSWORD} variable is not set!")

        password = str(password).encode('ascii', 'ignore').decode('ascii').strip()
        sender = str(sender).encode('ascii', 'ignore').decode('ascii').strip()
        recipient = str(recipient).encode('ascii', 'ignore').decode('ascii').strip()
        subject = str(subject).encode('ascii', 'ignore').decode('ascii').strip()
        
        body = str(body).replace('\xa0', ' ').strip()

        msg = MIMEMultipart()
        msg['From'] = sender
        msg['To'] = recipient
        msg['Subject'] = subject
        msg.attach(MIMEText(body, 'html', 'utf-8'))

        try:
            server = smtplib.SMTP('smtp.gmail.com', 587)
            server.starttls()
            server.login(sender, password)
            server.send_message(msg)
            server.quit()
            print(f"Successfully sent email to {recipient} with subject: {subject}")
        except Exception as e:
            raise Exception(f"Failed to send email: {str(e)}")

    def verify_email_and_extract_urls(self, email_address, subject, partial_body, retries=5, delay=10):
        password = BuiltIn().get_variable_value("${GMAIL_APP_PASSWORD}")
        
        if not password:
            raise Exception("CRITICAL ERROR: ${GMAIL_APP_PASSWORD} variable is not set in Copado UI!")
            
        try:
            from bs4 import BeautifulSoup
        except ImportError:
            raise Exception("CRITICAL ERROR: beautifulsoup4 is not installed. Pace.before did not run successfully.")

        for attempt in range(retries):
            try:
                mail = imaplib.IMAP4_SSL('imap.gmail.com')
                mail.login(email_address, password)
                mail.select('inbox')

                status, messages = mail.search(None, f'(SUBJECT "{subject}")')
                mail_ids = messages[0].split()

                if not mail_ids:
                    print(f"Email not found. Retrying in {delay} seconds... (Attempt {attempt + 1}/{retries})")
                    time.sleep(delay)
                    continue

                latest_email_id = mail_ids[-1]
                status, msg_data = mail.fetch(latest_email_id, '(RFC822)')
                
                for response_part in msg_data:
                    if isinstance(response_part, tuple):
                        msg = email.message_from_bytes(response_part[1])
                        
                        body_content = ""
                        if msg.is_multipart():
                            for part in msg.walk():
                                if part.get_content_type() == "text/html":
                                    body_content = part.get_payload(decode=True).decode()
                        else:
                            body_content = msg.get_payload(decode=True).decode()

                        if partial_body not in body_content:
                            raise Exception(f"Subject matched, but partial body '{partial_body}' was not found.")

                        soup = BeautifulSoup(body_content, 'lxml')
                        urls = [a['href'] for a in soup.find_all('a', href=True)]
                        
                        mail.quit()
                        return urls 

            except Exception as e:
                print(f"Error checking email: {str(e)}")
                
        raise Exception(f"Could not find the email with subject '{subject}' after {retries} attempts.")