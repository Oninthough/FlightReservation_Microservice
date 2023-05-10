package com.checkin.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;

import com.checkin.implementation.ReservationRestfulClient;
import com.checkin.implementation.dto.CheckinDto;
import com.checkin.implementation.dto.Reservation;

@Controller
public class CheckinController {
	@Autowired
	private ReservationRestfulClient restclient;
	
	@RequestMapping("/showCheckin")
	public String showCheckin()
	{
		return "showCheckin";
	}
	
	@RequestMapping("/startCheckin")
	public String proceedCheckin(@RequestParam("id") Long id,Model model)
	{
		Reservation reservation = restclient.findReservation(id);
		model.addAttribute("reservation",reservation);
		return "displayReservation";
	}
	
	@RequestMapping("/checkIn")
	public String boardingPass(@RequestParam("id") long id,@RequestParam("numberOfBags") int numberOfBags, Model model)
	{
		CheckinDto chek= new CheckinDto();
		chek.setId(id);
		chek.setNumberOfBags(numberOfBags);
		chek.setCheckedIn(true);
		Reservation reservation=restclient.generateBoardingPass(chek);
		model.addAttribute("reservation", reservation);
		return "confirmationPage";
	}
	

	

}
