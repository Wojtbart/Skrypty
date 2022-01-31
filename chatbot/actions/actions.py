# This files contains your custom actions which can be used to run
# custom Python code.
#
# See this guide on how to implement these action:
# https://rasa.com/docs/rasa/custom-actions

from typing import Any, Text, Dict, List
import json
from pathlib import Path
import datetime

from rasa_sdk import Action, Tracker, FormValidationAction
from rasa_sdk.events import SlotSet, EventType, Form, AllSlotsReset
from rasa_sdk.executor import CollectingDispatcher
from rasa_sdk.types import DomainDict


class ActionGetMenu(Action):
    def name(self) -> Text:
        return "action_menu"

    def run(self, dispatcher: CollectingDispatcher,tracker: Tracker,
            domain: Dict[Text, Any]) -> List[Dict[Text, Any]]:
        sentence=''
        with open("data/menu.json") as f:
        
            data=json.load(f)
            sentence+="Menu:\n"
            for row in data['items']:
                sentence+="Meal " + str(row['name'])+" -> price: "+str(row['price'])+ "$ -> preparation time: "+ str(row['preparation_time']*60)+" min\n"

        dispatcher.utter_message(sentence)
        return []

class ActionOpeningHours(Action):
    def name(self) -> Text:
        return "action_opening_hours"

    def run(self, dispatcher: CollectingDispatcher,tracker: Tracker,
            domain: Dict[Text, Any]):
        sentence=''
        with open("data/opening_hours.json") as f:
            data2=json.load(f)

            sentence+="Restaurant opening hours are:\n"
            for row in data2['items']:
                if(row!="Sunday"):
                    sentence+=row+ " "+str(data2['items'][row]['open'])+" - "+ str(data2['items'][row]['close'])+'\n'
            sentence+="It is closed on Sunday"

        dispatcher.utter_message(sentence)
        return []


class ActionOpeningHoursNow(Action):
    def name(self) -> Text:
        return "action_opening_hours_now"

    def run(self, dispatcher: CollectingDispatcher,tracker: Tracker,
            domain: Dict[Text, Any]):
        
        sentence=''
        with open("data/opening_hours.json") as f:
            data=json.load(f)

            date = datetime.datetime.now()
            date_name = date.date().strftime("%A") # np. Sunday
            open_time = data['items'][date_name]['open']
            close_time = data['items'][date_name]['close']
            sentence = "Restaurant is open in {} from {} to {}.".format(date_name, open_time, close_time)

        dispatcher.utter_message(sentence)
        return []


class ValidateRestaurantForm(FormValidationAction):
    def name(self)-> Text:
        return "validate_order_form"

    async def required_slots(self, slotsInDomain, dispatcher,tracker,domain):

        orderSlot = tracker.slots.get("orderSlot") # wartosc orderSlot

        orderCorrect = tracker.slots.get("orderCorrect") # wartosc orderCorrect
        if orderSlot is not None: # orderSlot pusty
            if orderCorrect is False: # orderCorrect niepoprawny
                return ["orderStop", "orderCorrect"] + slotsInDomain
            else:
                return ["orderCorrect"] + slotsInDomain
        return slotsInDomain

   # orderSlot
    async def extract_orderSlot(self, dispatcher,tracker,domain):
        lastIntent = tracker.get_intent_of_latest_message() # przetwarza ostatnia intencje uzytkownika
        orderSlot = tracker.slots.get("orderSlot") 

        if lastIntent =="what_you_have": # jezeli intencja to what_you_have
            return {"orderSlot": None}
        elif orderSlot is not None:
            return {"orderSlot": orderSlot}
        else:
            return {"orderSlot": tracker.latest_message['text']} 

    def validate_orderSlot(self,slotValue:Any, dispatcher: CollectingDispatcher,tracker: Tracker, domain: DomainDict) -> Dict[Text, Any]:
        return {"orderSlot": tracker.get_slot("orderSlot")}

    # orderCorrect
    async def extract_orderCorrect(self,dispatcher,tracker, domain):
        lastIntent = tracker.get_intent_of_latest_message() # przetwarza ostatnia intencje uzytkownika
        orderCorrect = tracker.get_slot("orderCorrect") # wartosc orderCorrect
        if orderCorrect is not None:
            return {"orderCorrect": orderCorrect}
        return {"orderCorrect": lastIntent == "affirm"}

    def validate_orderCorrect(self,slot_value, dispatcher,tracker,domain):
        return {"orderSlot": tracker.get_slot("orderSlot"), "orderCorrect": tracker.get_slot("orderCorrect")}

    # orderStop
    async def extract_orderStop(self, dispatcher,tracker,domain):
        lastIntent = tracker.get_intent_of_latest_message() # przetwarza ostatnia intencje uzytkownika
        return {"orderStop": lastIntent == "affirm"}  #zgoda

    def validate_orderStop(self,slot_value, dispatcher,tracker,domain):
        orderStop = tracker.get_slot("orderStop") # wartosc orderStop
        if not orderStop: # jezeli jest pusty
            return {"orderSlot": None, "orderCorrect": None, "orderStop": None}

        return {"orderSlot": tracker.get_slot("orderSlot"), "orderCorrect": tracker.get_slot("orderCorrect"), "orderStop": tracker.get_slot("orderStop")}

class ActionGetMenu(Action):
    def name(self) -> Text:
        return "action_take_order"

    def run(self, dispatcher: CollectingDispatcher,tracker: Tracker,
            domain: Dict[Text, Any]) -> List[Dict[Text, Any]]:
        
        if tracker.get_slot("orderStop") is not True: # jesli wartośc slotu 'orderSlot' jest pusta
            dispatcher.utter_message("The order has been accepted and is being processed")
        else:
            dispatcher.utter_message("The order has been cancelled")
        return [AllSlotsReset()] # resetuje wszystkie sloty

