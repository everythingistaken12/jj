return EventSystem.IsEventAvailable() == true and
	EventSystem.IsEventUsingTicketSystem() == true and
	EventSystem.GetUserEventTicketBalance() == 0 and
	EventSystem.GetSecondsUntilEventTicketsRefilled() < EventSystem.GetAvailableEventSecondsRemaining()