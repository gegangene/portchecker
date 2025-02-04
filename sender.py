#!pyvenv/bin/python3
import sys
import emails
import json

mailconfig={}
with open("mailconfig.json") as mailconfig_handler:
    mailconfig_str=""
    for line in mailconfig_handler:
        mailconfig_str+=line
    mailconfig=json.loads(mailconfig_str)

filearg=1

try:
    if(open(sys.argv[filearg])):
        with open(sys.argv[filearg]) as filehandle:
            message_text=filehandle.read()
            print(message_text)
    else:
        print("$2 should be a message .txt file")
        exit()

except:
    pass

#try:
#    if "@" in sys.argv[1]:
#        recipient=sys.argv[1]
#    else:
#        exit()

#except:
#    print("no given recipient adress in $1")
#    exit()

try:
    message_text
except:
    try:
        message_text=""
        for line in sys.stdin:
#            print(str(line))
            message_text+=str(line)
#        print(message_text)
    except:
        pass

try:
    if message_text:
        pass
except:
    print("message not given by txt in $2 nor pipe")
    exit()

#print(sys.argv)
if mailconfig["sender_domain"]!="":
    sender_email_address="portchecker@"+mailconfig["sender_domain"]
else:
    sender_email_address="portchecker@localhost"
message = emails.html(text=message_text, subject="portchecker alarm", mail_from=("portchecker-noreply",sender_email_address))
status = message.send(
        to=(mailconfig["recipient_addresses"]),
        smtp={"host": mailconfig["sender_server"], "port": mailconfig["sender_port"], "ssl": mailconfig["sender_ssl"], "user": mailconfig["sender_login"], "password": mailconfig["sender_password"]})
print(status)
