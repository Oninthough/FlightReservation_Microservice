package com.flight_reservation_app.service;

import java.util.Optional;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.flight_reservation_app.dto.EmailDetails;
import com.flight_reservation_app.dto.ReservationDto;
import com.flight_reservation_app.entities.Flight;
import com.flight_reservation_app.entities.Passanger;
import com.flight_reservation_app.entities.Reservation;
import com.flight_reservation_app.repository.FlightRepository;
import com.flight_reservation_app.repository.PassangerRepository;
import com.flight_reservation_app.repository.ReservationRepository;
import com.flight_reservation_app.utils.PdfGenerator;

@Service
public class ReservationServiceImpl implements ReservationService {
	@Autowired
	private ReservationRepository reservationRepo;
	@Autowired
	private PassangerRepository passangerRepo;
	
	@Autowired
	private FlightRepository flightRepo;
	@Autowired
	private EmailService emailser;

	@Override
	public Reservation bookFlight(ReservationDto request,EmailDetails details) {
		String filepath="C:\\Users\\ANINDYA GHOSH\\Desktop\\PSA\\projects";
		Passanger p= new Passanger();
		p.setFirstName(request.getFirstName());
		p.setMiddleName(request.getMiddleName());
		p.setLastName(request.getLastName());
		p.setEmail(request.getEmail());
		p.setPhone(request.getPhone());
		Passanger savedPassanger = passangerRepo.save(p);
		
		Optional<Flight> findFlight = flightRepo.findById(request.getFlightId());
		Flight flight = findFlight.get();
		
		Reservation r = new Reservation();
		r.setPassanger(savedPassanger);
		r.setFlight(flight);
		r.setNumberOfBags(0);
		r.setCheckedIn(false);
		Reservation savedReservation = reservationRepo.save(r);
		PdfGenerator pdf= new PdfGenerator();
		pdf.generatePDF(filepath+p.getId()+".pdf", request.getFirstName(), request.getEmail(), (String)savedReservation.getPassanger().getPhone(),
				(String)savedReservation.getFlight().getOperatingAirlines(), flight.getDateOfDeparture(), flight.getDepartureCity()
				, flight.getArrivalCity());
		
		
		
		details.setSubject("Confirmation mail for flight booking");
		details.setMsgBody("Your Ticket is confirmed. Ticket is Attached below");
		details.setRecipient(request.getEmail());
		details.setAttachment(filepath+p.getId()+".pdf");
		emailser.sendMailWithAttachment(details);
		return savedReservation;
	}

}
