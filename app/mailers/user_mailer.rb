class UserMailer < ApplicationMailer
  def email_confirmation(user, confirmation_url)
    @user = user
    @confirmation_url = confirmation_url
    
    body = <<~EMAIL
      Hello #{@user.username},
      
      You have requested to change your email address to: #{@user.new_email}
      
      Please click the following link to confirm this change:
      #{@confirmation_url}
      
      This link will expire in 24 hours.
      
      If you did not request this change, please ignore this email.
      
      Best regards,
      Community Poll Hub Team
    EMAIL
    
    mail(
      to: @user.new_email,
      subject: "Confirm your new email address",
      body: body
    )
  end
end
