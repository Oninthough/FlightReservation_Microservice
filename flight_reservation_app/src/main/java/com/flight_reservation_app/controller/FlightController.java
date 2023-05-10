package com.flight_reservation_app.controller;


import java.util.Date;
import java.util.List;
import java.util.Optional;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;

import com.flight_reservation_app.entities.Flight;
import com.flight_reservation_app.repository.FlightRepository;

@Controller
public class FlightController {
	@Autowired
	private FlightRepository flightRepo;
	
	@RequestMapping("/findFlights")
	public String findFlight(@RequestParam("to") String to, @RequestParam("from") String from, 
			@RequestParam("departureDate") @DateTimeFormat(pattern = "MM-dd-yyyy") Date departureDate, Model model )
	{
		List<Flight> flights = flightRepo.findFlights(to,from,departureDate);
		model.addAttribute("findFlight", flights);
		return "displayFlights";
	}
	
	@RequestMapping("/selectFlight")
	public String bookspecificFlight(@RequestParam("flightId") long flightId, Model model)
	{
		System.out.println(flightId);
		Optional<Flight> oneFlight = flightRepo.findById(flightId);
		Flight flight = oneFlight.get();
		System.out.println(flight.getFlightNumber());
		model.addAttribute("flight", flight);
		return "bookFlight";
	}
	
	

}
