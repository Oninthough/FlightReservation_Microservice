package com.flight_reservation_app.service;

import com.flight_reservation_app.dto.EmailDetails;

public interface EmailService {
	 
    // Method
    // To send a simple email
    //String sendSimpleMail(EmailDetails details);
 
    // Method
    // To send an email with attachment
    String sendMailWithAttachment(EmailDetails details);
}