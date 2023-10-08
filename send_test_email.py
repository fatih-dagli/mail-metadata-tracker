$smtpServer = "email-smtp.us-east-1.amazonaws.com" # SES SMTP endpoint
$smtpFrom = "<EMAIL_ADDRESS>" # from email address
$smtpTo = "<EMAIL_ADDRESS>" # to email address
$messageSubject = "Test Email" # Subject
$messageBody = "This is a test email sent via AWS SES SMTP." # Content

# SMTP Credentials
$smtpUsername = "<SMTP_USER_ACCESS_KEY_OR_USERNAME>" 
$smtpPassword = "<SMTP_PASSWORD>" 

# Sent Email
Send-MailMessage -SmtpServer $smtpServer -Port 587 -From $smtpFrom -To $smtpTo -Subject $messageSubject -Body $messageBody -UseSsl -Credential (New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $smtpUsername, (ConvertTo-SecureString -String $smtpPassword -AsPlainText -Force))
