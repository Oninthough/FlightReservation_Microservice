package com.flight_reservation_app.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestMapping;

import com.flight_reservation_app.dto.EmailDetails;
import com.flight_reservation_app.dto.ReservationDto;
import com.flight_reservation_app.entities.Passanger;
import com.flight_reservation_app.entities.Reservation;
import com.flight_reservation_app.service.EmailService;
import com.flight_reservation_app.service.ReservationService;

@Controller
public class ReservationController {
	@Autowired
	private ReservationService reservationService;

	
	@RequestMapping("/completeReservation")
	public String completeReservation(ReservationDto request,EmailDetails details, Model model)
	{
		
		Reservation reserved=reservationService.bookFlight(request,details);
		model.addAttribute("reservedId", reserved.getId());
		return "confirmReservation";
	}

}
