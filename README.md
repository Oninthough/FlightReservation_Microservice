# FlightReservation_Microservice
Here we have created two seperate project in Spring boot. Following business flow first flight_reservation_app will be exicuted

which will be used to save passanger,fligt details and ticket reservation is done through this project. for that OneToOne mapping is done between passanger and flight

Pdf ticket generation and mailing the same is implemented where external api integretion is done.

After ticket reservation is done the flight and passanger details(ie. reservation details) is sent through a rest Controller, that api can be test in Postman

Fetched that api to checkin project using RestTemplate and formed tha Reservation object back.using that checkin module is created

and boarding pass is generated at the end
