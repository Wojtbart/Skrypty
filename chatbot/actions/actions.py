# This files contains your custom actions which can be used to run
# custom Python code.
#
# See this guide on how to implement these action:
# https://rasa.com/docs/rasa/custom-actions

from typing import Any, Text, Dict, List
import json
from pathlib import Path

from rasa_sdk import Action, Tracker
from rasa_sdk.events import SlotSet,EventType, Form
from rasa_sdk.executor import CollectingDispatcher

class ActionOrderId(Action):
    def name(self) -> Text:
        return "action_order_id"

    async def run(self, dispatcher: CollectingDispatcher,tracker: Tracker,
            domain: Dict[Text, Any]) -> List[Dict[Text, Any]]:
        order_id=tracker.sender_id
        dispatcher.utter_message("Your order number is {}".format(order_id))

class ActionAskOrder(Action):
    def name(self) -> Text:
        return "action_ask_order"

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
            domain: Dict[Text, Any]) -> List[Dict[Text, Any]]:
        
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


class ActionFormInfo(Action):
    def name(self)-> Text:
        return "form info"

    @staticmethod
    def required_slots(tracker: Tracker):
        return ["food","size", "quantity", "number","name"]

    def submit(self, dispatcher: CollectingDispatcher,tracker: Tracker,
            domain: Dict[Text, Any]):
        dispatcher.utter_message(template="utter_thanks", name=tracker.get_slot('name'), 
        order=tracker.sender_id)
        dispatcher.utter_message(template="utter_food", quantity=tracker.get_slot('quantity'))

        return []

    def slot_mappings(self):
        return {
            "name": [self.from_entity(entity="name", intent='provide_name'), self.from_text()],
            "food": [self.from_entity(entity="food", intent='food'), self.from_text()],
            "quantity": [self.from_entity(entity="quantity", intent='quantity'), self.from_text()],
            "number": [self.from_entity(entity="number", intent='provide_number'), self.from_text()]
        }




# class ActionCheckExistence(Action):

#     def name(self) -> Text:
#         return "action_get_food_from_user"

#     def run(self, dispatcher: CollectingDispatcher,
#             tracker: Tracker,
#             domain: Dict[Text, Any]) -> List[Dict[Text, Any]]:

#         for blob in tracker.latest_message['entities']:
            # print(tracker.latest_message)
#             if blob['entity']=='food':
#                 name=blob['value']
#                 if name in self.data:
#                     dispatcher.utter_message(text="Hello World!")
#                 else:
#                     dispatcher.utter_message(text="else Hello World!")

#         return []  
