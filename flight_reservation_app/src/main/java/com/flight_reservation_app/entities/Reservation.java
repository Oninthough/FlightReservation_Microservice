package com.flight_reservation_app.entities;

import javax.persistence.Entity;
import javax.persistence.OneToOne;

@Entity
public class Reservation extends AbstructEntity{
	private boolean checkedIn;
	private int numberOfBags;
	@OneToOne
	private Passanger passanger;// onetoone mapping so foreign key is used, as one passanger can book only one flight
	@OneToOne
	private Flight flight;// onetoone mapping so foreign key is used
	public boolean isCheckedIn() {
		return checkedIn;
	}
	public void setCheckedIn(boolean checkedIn) {
		this.checkedIn = checkedIn;
	}
	public int getNumberOfBags() {
		return numberOfBags;
	}
	public void setNumberOfBags(int numberOfBags) {
		this.numberOfBags = numberOfBags;
	}
	public Passanger getPassanger() {
		return passanger;
	}
	public void setPassanger(Passanger passanger) {
		this.passanger = passanger;
	}
	public Flight getFlight() {
		return flight;
	}
	public void setFlight(Flight flight) {
		this.flight = flight;
	}
	
	
}
