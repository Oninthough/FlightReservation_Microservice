package com.checkin.implementation.dto;

public class Reservation{
	private long id;
	private boolean checkedIn;
	private int numberOfBags;
	private Passanger passanger;// onetoone mapping so foreign key is used, as one passanger can book only one flight
	private Flight flight;// onetoone mapping so foreign key is used
	
	
	
	public long getId() {
		return id;
	}
	public void setId(long id) {
		this.id = id;
	}
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
