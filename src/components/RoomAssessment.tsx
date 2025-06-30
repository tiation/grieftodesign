
import { useState } from "react";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Checkbox } from "@/components/ui/checkbox";
import { Badge } from "@/components/ui/badge";
import { Home, CheckCircle, XCircle, AlertTriangle } from "lucide-react";

interface RoomAssessmentProps {
  selectedAge: string;
}

const RoomAssessment = ({ selectedAge }: RoomAssessmentProps) => {
  const [checkedItems, setCheckedItems] = useState<Record<string, boolean>>({});
  const [selectedRoom, setSelectedRoom] = useState("kitchen");

  const rooms = {
    kitchen: {
      name: "Kitchen",
      icon: "🍳",
      checklistItems: [
        "Cabinet locks on lower cabinets",
        "Oven locks or knob covers",
        "Sharp objects secured in locked drawers",
        "Electrical outlet covers",
        "Refrigerator lock",
        "Stove guards installed",
        "Non-slip mats on floors",
        "Cleaning supplies locked away",
      ],
    },
    bathroom: {
      name: "Bathroom",
      icon: "🛁",
      checklistItems: [
        "Toilet locks installed",
        "Bath mats with suction cups",
        "Water temperature regulated (120°F max)",
        "Medications locked in cabinet",
        "Electrical items away from water",
        "Door knob covers",
        "Razor and sharp items secured",
        "Non-slip strips in bathtub",
      ],
    },
    stairs: {
      name: "Stairs",
      icon: "🪜",
      checklistItems: [
        "Safety gates at top and bottom",
        "Handrails secure and appropriate height",
        "No loose carpeting or objects",
        "Adequate lighting",
        "Baluster spacing less than 4 inches",
        "Non-slip treads installed",
        "Clear sight lines",
        "Emergency lighting available",
      ],
    },
    bedroom: {
      name: "Bedroom",
      icon: "🛏️",
      checklistItems: [
        "Crib meets current safety standards",
        "Window guards or stops installed",
        "Blind cords cut or secured",
        "Heavy furniture anchored to wall",
        "Small objects removed from reach",
        "Outlet covers installed",
        "Door knob covers if needed",
        "Night lights for visibility",
      ],
    },
  };

  const handleCheckChange = (itemIndex: number, roomKey: string) => {
    const key = `${roomKey}-${itemIndex}`;
    setCheckedItems(prev => ({
      ...prev,
      [key]: !prev[key],
    }));
  };

  const getCompletionRate = (roomKey: string) => {
    const room = rooms[roomKey as keyof typeof rooms];
    const totalItems = room.checklistItems.length;
    const checkedCount = room.checklistItems.filter((_, index) => 
      checkedItems[`${roomKey}-${index}`]
    ).length;
    return Math.round((checkedCount / totalItems) * 100);
  };

  const selectedRoomData = rooms[selectedRoom as keyof typeof rooms];
  const completionRate = getCompletionRate(selectedRoom);

  return (
    <div className="space-y-6">
      {/* Room Selection */}
      <Card>
        <CardHeader>
          <CardTitle className="flex items-center space-x-2">
            <Home className="h-5 w-5 text-blue-500" />
            <span>Room-by-Room Safety Assessment</span>
          </CardTitle>
          <CardDescription>
            Interactive checklist to evaluate and improve safety in each area of your home
          </CardDescription>
        </CardHeader>
        <CardContent>
          <div className="grid grid-cols-2 md:grid-cols-4 gap-3">
            {Object.entries(rooms).map(([key, room]) => {
              const completion = getCompletionRate(key);
              return (
                <Button
                  key={key}
                  variant={selectedRoom === key ? "default" : "outline"}
                  onClick={() => setSelectedRoom(key)}
                  className="h-auto p-4 flex flex-col items-center space-y-2"
                >
                  <div className="text-2xl">{room.icon}</div>
                  <div className="text-center">
                    <div className="font-medium">{room.name}</div>
                    <Badge 
                      variant="secondary" 
                      className={`text-xs ${
                        completion === 100 ? "bg-green-100 text-green-700" : 
                        completion >= 75 ? "bg-blue-100 text-blue-700" :
                        completion >= 50 ? "bg-yellow-100 text-yellow-700" :
                        "bg-red-100 text-red-700"
                      }`}
                    >
                      {completion}%
                    </Badge>
                  </div>
                </Button>
              );
            })}
          </div>
        </CardContent>
      </Card>

      {/* Room Checklist */}
      <Card>
        <CardHeader>
          <CardTitle className="flex items-center justify-between">
            <span className="flex items-center space-x-2">
              <span className="text-2xl">{selectedRoomData.icon}</span>
              <span>{selectedRoomData.name} Safety Checklist</span>
            </span>
            <div className="flex items-center space-x-2">
              {completionRate === 100 ? (
                <CheckCircle className="h-5 w-5 text-green-500" />
              ) : completionRate >= 75 ? (
                <AlertTriangle className="h-5 w-5 text-yellow-500" />
              ) : (
                <XCircle className="h-5 w-5 text-red-500" />
              )}
              <Badge variant="outline">
                {completionRate}% Complete
              </Badge>
            </div>
          </CardTitle>
        </CardHeader>
        <CardContent>
          <div className="space-y-4">
            {selectedRoomData.checklistItems.map((item, index) => {
              const isChecked = checkedItems[`${selectedRoom}-${index}`] || false;
              return (
                <div
                  key={index}
                  className={`flex items-center space-x-3 p-3 rounded-lg border transition-colors ${
                    isChecked ? "bg-green-50 border-green-200" : "bg-gray-50 border-gray-200"
                  }`}
                >
                  <Checkbox
                    id={`${selectedRoom}-${index}`}
                    checked={isChecked}
                    onCheckedChange={() => handleCheckChange(index, selectedRoom)}
                  />
                  <label
                    htmlFor={`${selectedRoom}-${index}`}
                    className={`flex-1 cursor-pointer ${
                      isChecked ? "text-green-800 line-through" : "text-gray-700"
                    }`}
                  >
                    {item}
                  </label>
                  {isChecked && (
                    <CheckCircle className="h-4 w-4 text-green-500" />
                  )}
                </div>
              );
            })}
          </div>

          {/* Progress Summary */}
          <div className="mt-6 p-4 bg-blue-50 rounded-lg">
            <div className="flex items-center justify-between mb-2">
              <span className="font-medium text-blue-900">Safety Progress</span>
              <span className="text-sm text-blue-700">
                {selectedRoomData.checklistItems.filter((_, index) => 
                  checkedItems[`${selectedRoom}-${index}`]
                ).length} of {selectedRoomData.checklistItems.length} items completed
              </span>
            </div>
            <div className="w-full bg-blue-200 rounded-full h-2">
              <div
                className="bg-blue-600 h-2 rounded-full transition-all duration-300"
                style={{ width: `${completionRate}%` }}
              ></div>
            </div>
          </div>
        </CardContent>
      </Card>
    </div>
  );
};

export default RoomAssessment;
