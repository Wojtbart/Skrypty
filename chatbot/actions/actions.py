# This files contains your custom actions which can be used to run
# custom Python code.
#
# See this guide on how to implement these action:
# https://rasa.com/docs/rasa/custom-actions


from typing import Any, Text, Dict, List
import json
from pathlib import Path

from rasa_sdk import Action, Tracker
from rasa_sdk.executor import CollectingDispatcher


class ActionHelloWorld(Action):

    def name(self) -> Text:
        return "action_hello_world"

    def run(self, dispatcher: CollectingDispatcher,
            tracker: Tracker,
            domain: Dict[Text, Any]) -> List[Dict[Text, Any]]:

        dispatcher.utter_message(text="Hello World!")

        return []

class ActionCheckExistence(Action):
    # data=Path("data/opening_hours.json").read_text.split("\n")
    f=open('data/menu.json')
    data=json.load(f)

    def name(self) -> Text:
        return "action_check_existence"

    def run(self, dispatcher: CollectingDispatcher,
            tracker: Tracker,
            domain: Dict[Text, Any]) -> List[Dict[Text, Any]]:

        for blob in tracker.latest_message['entities']:
            print(tracker.latest_message)
            if blob['entity']=='pokemon_name':
                name=blob['value']
                if name in self.data:
                    dispatcher.utter_message(text="Hello World!")
                else:
                    dispatcher.utter_message(text="else Hello World!")

        return []  
