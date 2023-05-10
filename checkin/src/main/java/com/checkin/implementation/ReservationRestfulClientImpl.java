package com.checkin.implementation;

import org.springframework.stereotype.Component;
import org.springframework.web.client.RestTemplate;

import com.checkin.implementation.dto.CheckinDto;
import com.checkin.implementation.dto.Reservation;

@Component
public class ReservationRestfulClientImpl implements ReservationRestfulClient {

	@Override
	public Reservation findReservation(Long id) {
		RestTemplate restTemplate= new RestTemplate();
		Reservation reservation = restTemplate.getForObject("http://localhost:8080/flights/reservation/"+id, Reservation.class);
		return reservation;
	}

	@Override
	public Reservation generateBoardingPass(CheckinDto chek) {
		RestTemplate res= new RestTemplate();
		Reservation reservation = res.postForObject("http://localhost:8080/flights/reservation/", chek,Reservation.class);
		// TODO Auto-generated method stub
		return reservation;
		
	}
	

}
