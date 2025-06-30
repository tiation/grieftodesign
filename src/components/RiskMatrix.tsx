
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { AlertTriangle, AlertCircle, CheckCircle } from "lucide-react";

interface RiskMatrixProps {
  selectedAge: string;
}

const RiskMatrix = ({ selectedAge }: RiskMatrixProps) => {
  const getRiskData = (age: string) => {
    const baseData = [
      { area: "Kitchen", likelihood: "High", severity: "High", percentage: "23%", description: "Burns, cuts, poisoning" },
      { area: "Stairs", likelihood: "Medium", severity: "High", percentage: "18%", description: "Falls, head injuries" },
      { area: "Bathroom", likelihood: "Medium", severity: "Medium", percentage: "15%", description: "Drowning, slips" },
      { area: "Living Room", likelihood: "Medium", severity: "Low", percentage: "12%", description: "Furniture tips, small objects" },
      { area: "Bedroom", likelihood: "Low", severity: "Medium", percentage: "10%", description: "Suffocation, falls from bed" },
      { area: "Garage/Basement", likelihood: "Low", severity: "High", percentage: "8%", description: "Tools, chemicals, falls" },
      { area: "Backyard", likelihood: "Medium", severity: "Medium", percentage: "14%", description: "Playground equipment, pools" },
    ];

    // Adjust data based on age
    if (age === "infant") {
      baseData[4].likelihood = "High"; // Bedroom more risky for infants
      baseData[3].likelihood = "Low"; // Living room less risky
    } else if (age === "child") {
      baseData[6].likelihood = "High"; // Backyard more risky for older children
      baseData[0].percentage = "20%"; // Kitchen slightly less risky
    }

    return baseData;
  };

  const getRiskColor = (likelihood: string, severity: string) => {
    if (likelihood === "High" && severity === "High") return "bg-red-100 text-red-800 border-red-200";
    if ((likelihood === "High" && severity === "Medium") || (likelihood === "Medium" && severity === "High")) 
      return "bg-orange-100 text-orange-800 border-orange-200";
    if (likelihood === "Medium" && severity === "Medium") return "bg-yellow-100 text-yellow-800 border-yellow-200";
    return "bg-green-100 text-green-800 border-green-200";
  };

  const getRiskIcon = (likelihood: string, severity: string) => {
    if (likelihood === "High" && severity === "High") return <AlertTriangle className="h-4 w-4" />;
    if ((likelihood === "High" && severity === "Medium") || (likelihood === "Medium" && severity === "High")) 
      return <AlertCircle className="h-4 w-4" />;
    return <CheckCircle className="h-4 w-4" />;
  };

  const riskData = getRiskData(selectedAge);

  return (
    <div className="space-y-4 sm:space-y-6">
      <Card>
        <CardHeader className="pb-4 sm:pb-6">
          <CardTitle className="flex items-center space-x-2 text-base sm:text-lg">
            <AlertTriangle className="h-4 w-4 sm:h-5 sm:w-5 text-orange-500" />
            <span>Home Safety Risk Matrix</span>
          </CardTitle>
          <CardDescription className="text-sm">
            Statistical breakdown of injury risks by home area for {selectedAge}s
          </CardDescription>
        </CardHeader>
        <CardContent className="px-4 sm:px-6">
          <div className="grid gap-3 sm:gap-4">
            {riskData.map((item, index) => (
              <div
                key={index}
                className={`p-3 sm:p-4 rounded-lg border-2 transition-all hover:shadow-md ${getRiskColor(
                  item.likelihood,
                  item.severity
                )}`}
              >
                <div className="flex items-center justify-between mb-2 sm:mb-3">
                  <div className="flex items-center space-x-2 sm:space-x-3">
                    {getRiskIcon(item.likelihood, item.severity)}
                    <h4 className="font-semibold text-base sm:text-lg">{item.area}</h4>
                  </div>
                  <div className="text-right">
                    <div className="font-bold text-lg sm:text-xl">{item.percentage}</div>
                    <div className="text-xs opacity-80">of injuries</div>
                  </div>
                </div>
                
                <div className="flex flex-col sm:flex-row sm:items-center justify-between text-xs sm:text-sm mb-2">
                  <div className="flex flex-col sm:flex-row sm:space-x-4 space-y-1 sm:space-y-0">
                    <div>
                      <span className="font-medium">Likelihood:</span> {item.likelihood}
                    </div>
                    <div>
                      <span className="font-medium">Severity:</span> {item.severity}
                    </div>
                  </div>
                </div>
                
                <p className="text-xs sm:text-sm opacity-90">{item.description}</p>
              </div>
            ))}
          </div>
        </CardContent>
      </Card>

      {/* Risk Legend - Mobile optimized */}
      <Card>
        <CardHeader className="pb-3 sm:pb-6">
          <CardTitle className="text-base sm:text-lg">Risk Level Guide</CardTitle>
        </CardHeader>
        <CardContent className="px-4 sm:px-6">
          <div className="grid grid-cols-2 sm:grid-cols-4 gap-2 sm:gap-3">
            <div className="flex items-center space-x-2">
              <div className="w-3 h-3 sm:w-4 sm:h-4 bg-red-200 rounded border-2 border-red-300"></div>
              <span className="text-xs sm:text-sm">Critical Risk</span>
            </div>
            <div className="flex items-center space-x-2">
              <div className="w-3 h-3 sm:w-4 sm:h-4 bg-orange-200 rounded border-2 border-orange-300"></div>
              <span className="text-xs sm:text-sm">High Risk</span>
            </div>
            <div className="flex items-center space-x-2">
              <div className="w-3 h-3 sm:w-4 sm:h-4 bg-yellow-200 rounded border-2 border-yellow-300"></div>
              <span className="text-xs sm:text-sm">Moderate Risk</span>
            </div>
            <div className="flex items-center space-x-2">
              <div className="w-3 h-3 sm:w-4 sm:h-4 bg-green-200 rounded border-2 border-green-300"></div>
              <span className="text-xs sm:text-sm">Low Risk</span>
            </div>
          </div>
        </CardContent>
      </Card>
    </div>
  );
};

export default RiskMatrix;
