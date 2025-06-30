
import { Button } from "@/components/ui/button";
import { Card, CardContent } from "@/components/ui/card";
import { Baby, Users, GraduationCap } from "lucide-react";

interface AgeSelectorProps {
  selectedAge: string;
  onAgeChange: (age: string) => void;
}

const AgeSelector = ({ selectedAge, onAgeChange }: AgeSelectorProps) => {
  const ageGroups = [
    {
      id: "infant",
      label: "Infants",
      range: "0-12 months",
      icon: Baby,
      color: "bg-pink-100 text-pink-700",
    },
    {
      id: "toddler",
      label: "Toddlers",
      range: "1-3 years",
      icon: Users,
      color: "bg-blue-100 text-blue-700",
    },
    {
      id: "child",
      label: "Children",
      range: "4-12 years",
      icon: GraduationCap,
      color: "bg-green-100 text-green-700",
    },
  ];

  return (
    <Card>
      <CardContent className="p-4 sm:p-6">
        <h3 className="text-base sm:text-lg font-semibold mb-3 sm:mb-4 text-center">Select Child's Age Group</h3>
        <div className="grid grid-cols-1 sm:grid-cols-3 gap-3 sm:gap-4">
          {ageGroups.map((group) => {
            const Icon = group.icon;
            const isSelected = selectedAge === group.id;
            
            return (
              <Button
                key={group.id}
                variant={isSelected ? "default" : "outline"}
                onClick={() => onAgeChange(group.id)}
                className={`h-auto p-3 sm:p-4 flex flex-col items-center space-y-2 transition-all ${
                  isSelected ? "" : "hover:bg-gray-50"
                }`}
              >
                <div className={`p-2 rounded-full ${isSelected ? "bg-white/20" : group.color}`}>
                  <Icon className={`h-5 w-5 sm:h-6 sm:w-6 ${isSelected ? "text-white" : ""}`} />
                </div>
                <div className="text-center">
                  <div className={`font-medium text-sm sm:text-base ${isSelected ? "text-white" : "text-gray-900"}`}>
                    {group.label}
                  </div>
                  <div className={`text-xs sm:text-sm ${isSelected ? "text-white/80" : "text-gray-500"}`}>
                    {group.range}
                  </div>
                </div>
              </Button>
            );
          })}
        </div>
      </CardContent>
    </Card>
  );
};

export default AgeSelector;
