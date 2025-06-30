
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { AlertTriangle, Shield, Eye, Home } from "lucide-react";

interface SafetyTipsProps {
  selectedAge: string;
}

const SafetyTips = ({ selectedAge }: SafetyTipsProps) => {
  const getSafetyTips = (age: string) => {
    const commonTips = [
      {
        category: "General Safety",
        icon: Shield,
        color: "bg-blue-100 text-blue-800",
        tips: [
          "Install safety gates at the top and bottom of stairs",
          "Secure heavy furniture and TVs to walls",
          "Cover electrical outlets with safety plugs",
          "Keep small objects that pose choking hazards out of reach",
        ],
      },
      {
        category: "Kitchen Safety",
        icon: AlertTriangle,
        color: "bg-red-100 text-red-800",
        tips: [
          "Use cabinet locks on lower cabinets",
          "Install oven locks and stove knob covers",
          "Keep knives and sharp objects in locked drawers",
          "Store cleaning supplies in high cabinets with locks",
        ],
      },
      {
        category: "Bathroom Safety",
        icon: Home,
        color: "bg-green-100 text-green-800",
        tips: [
          "Use non-slip mats in the bathtub",
          "Set water heater to 120°F (49°C) or below",
          "Install toilet locks to prevent drowning",
          "Keep medications in locked cabinets",
        ],
      },
      {
        category: "Supervision",
        icon: Eye,
        color: "bg-yellow-100 text-yellow-800",
        tips: [
          "Never leave children unattended near water",
          "Maintain visual contact in high-risk areas",
          "Teach children about potential dangers",
          "Create safe play areas with appropriate supervision",
        ],
      },
    ];

    // Customize tips based on age
    if (age === "infant") {
      commonTips[0].tips.push("Ensure crib meets current safety standards");
      commonTips[1].tips.push("Remove or secure any dangling cords");
      commonTips[3].tips = [
        "Constant supervision required",
        "Safe sleep practices (back sleeping)",
        "Regular safety checks of environment",
        "Age-appropriate toys only",
      ];
    } else if (age === "toddler") {
      commonTips[0].tips.push("Install window guards or stops");
      commonTips[2].tips.push("Use toilet seat locks");
      commonTips[3].tips = [
        "Active supervision during play",
        "Teach basic safety rules",
        "Childproof all accessible areas",
        "Monitor outdoor play constantly",
      ];
    } else if (age === "child") {
      commonTips[0].tips.push("Teach proper stair safety");
      commonTips[3].tips = [
        "Establish clear safety rules",
        "Supervised independence in safe areas",
        "Teach emergency procedures",
        "Regular safety discussions",
      ];
    }

    return commonTips;
  };

  const safetyTips = getSafetyTips(selectedAge);
  const ageLabels = {
    infant: "Infants (0-12 months)",
    toddler: "Toddlers (1-3 years)",
    child: "Children (4-12 years)",
  };

  return (
    <div className="space-y-6">
      <Card>
        <CardHeader>
          <CardTitle className="flex items-center space-x-2">
            <Shield className="h-5 w-5 text-green-500" />
            <span>Safety Tips for {ageLabels[selectedAge as keyof typeof ageLabels]}</span>
          </CardTitle>
          <CardDescription>
            Evidence-based safety recommendations to prevent accidents and injuries
          </CardDescription>
        </CardHeader>
      </Card>

      <div className="grid gap-6 md:grid-cols-2">
        {safetyTips.map((category, index) => {
          const Icon = category.icon;
          return (
            <Card key={index} className="h-full">
              <CardHeader>
                <CardTitle className="flex items-center space-x-2">
                  <div className={`p-2 rounded-full ${category.color}`}>
                    <Icon className="h-4 w-4" />
                  </div>
                  <span className="text-lg">{category.category}</span>
                </CardTitle>
              </CardHeader>
              <CardContent>
                <ul className="space-y-3">
                  {category.tips.map((tip, tipIndex) => (
                    <li key={tipIndex} className="flex items-start space-x-2">
                      <div className="w-2 h-2 bg-gray-400 rounded-full mt-2 flex-shrink-0"></div>
                      <span className="text-sm text-gray-700">{tip}</span>
                    </li>
                  ))}
                </ul>
              </CardContent>
            </Card>
          );
        })}
      </div>

      {/* Emergency Information */}
      <Card className="border-red-200 bg-red-50">
        <CardHeader>
          <CardTitle className="flex items-center space-x-2 text-red-800">
            <AlertTriangle className="h-5 w-5" />
            <span>Emergency Information</span>
          </CardTitle>
        </CardHeader>
        <CardContent>
          <div className="grid gap-4 sm:grid-cols-2">
            <div>
              <h4 className="font-semibold text-red-800 mb-2">Emergency Numbers</h4>
              <ul className="text-sm text-red-700 space-y-1">
                <li>Emergency: 911</li>
                <li>Poison Control: 1-800-222-1222</li>
                <li>Local Hospital: Keep number handy</li>
              </ul>
            </div>
            <div>
              <h4 className="font-semibold text-red-800 mb-2">First Aid Essentials</h4>
              <ul className="text-sm text-red-700 space-y-1">
                <li>Keep first aid kit accessible</li>
                <li>Learn basic CPR and first aid</li>
                <li>Post emergency numbers visibly</li>
              </ul>
            </div>
          </div>
        </CardContent>
      </Card>
    </div>
  );
};

export default SafetyTips;
