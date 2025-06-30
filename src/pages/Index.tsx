
import { useState } from "react";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import { AlertTriangle, Home, Shield, Users, BarChart3, Menu } from "lucide-react";
import RiskMatrix from "../components/RiskMatrix";
import RoomAssessment from "../components/RoomAssessment";
import SafetyTips from "../components/SafetyTips";
import AgeSelector from "../components/AgeSelector";

const Index = () => {
  const [selectedAge, setSelectedAge] = useState("toddler");
  const [activeView, setActiveView] = useState("matrix");

  return (
    <div className="min-h-screen bg-gradient-to-br from-blue-50 via-white to-green-50">
      {/* Header - Optimized for mobile */}
      <header className="bg-white shadow-sm border-b sticky top-0 z-10">
        <div className="max-w-7xl mx-auto px-3 sm:px-6 lg:px-8 py-4 sm:py-6">
          <div className="flex items-center justify-between">
            <div className="flex items-center space-x-2 sm:space-x-3">
              <div className="bg-blue-600 p-1.5 sm:p-2 rounded-lg">
                <Shield className="h-4 w-4 sm:h-6 sm:w-6 text-white" />
              </div>
              <div>
                <h1 className="text-lg sm:text-2xl font-bold text-gray-900">HomeSafe Matrix</h1>
                <p className="text-xs sm:text-sm text-gray-600 hidden sm:block">Statistical home safety assessment for children</p>
              </div>
            </div>
            <div className="flex items-center space-x-2 sm:space-x-4">
              <Badge variant="outline" className="bg-green-50 text-green-700 text-xs px-2 py-1">
                <Users className="h-2 w-2 sm:h-3 sm:w-3 mr-1" />
                <span className="hidden sm:inline">Evidence-Based</span>
                <span className="sm:hidden">Verified</span>
              </Badge>
            </div>
          </div>
        </div>
      </header>

      {/* Main Content */}
      <main className="max-w-7xl mx-auto px-3 sm:px-6 lg:px-8 py-4 sm:py-8">
        {/* Age Selection */}
        <div className="mb-6 sm:mb-8">
          <AgeSelector selectedAge={selectedAge} onAgeChange={setSelectedAge} />
        </div>

        {/* Navigation Tabs - Mobile optimized */}
        <div className="mb-6 sm:mb-8">
          <nav className="flex space-x-1 bg-gray-100 p-1 rounded-lg overflow-x-auto">
            <Button
              variant={activeView === "matrix" ? "default" : "ghost"}
              onClick={() => setActiveView("matrix")}
              className="flex-1 min-w-0 text-xs sm:text-sm px-2 sm:px-4 whitespace-nowrap"
            >
              <BarChart3 className="h-3 w-3 sm:h-4 sm:w-4 mr-1 sm:mr-2" />
              <span className="hidden sm:inline">Risk Matrix</span>
              <span className="sm:hidden">Risks</span>
            </Button>
            <Button
              variant={activeView === "rooms" ? "default" : "ghost"}
              onClick={() => setActiveView("rooms")}
              className="flex-1 min-w-0 text-xs sm:text-sm px-2 sm:px-4 whitespace-nowrap"
            >
              <Home className="h-3 w-3 sm:h-4 sm:w-4 mr-1 sm:mr-2" />
              <span className="hidden sm:inline">Room Assessment</span>
              <span className="sm:hidden">Rooms</span>
            </Button>
            <Button
              variant={activeView === "tips" ? "default" : "ghost"}
              onClick={() => setActiveView("tips")}
              className="flex-1 min-w-0 text-xs sm:text-sm px-2 sm:px-4 whitespace-nowrap"
            >
              <AlertTriangle className="h-3 w-3 sm:h-4 sm:w-4 mr-1 sm:mr-2" />
              <span className="hidden sm:inline">Safety Tips</span>
              <span className="sm:hidden">Tips</span>
            </Button>
          </nav>
        </div>

        {/* Content Views */}
        <div className="space-y-6 sm:space-y-8">
          {activeView === "matrix" && <RiskMatrix selectedAge={selectedAge} />}
          {activeView === "rooms" && <RoomAssessment selectedAge={selectedAge} />}
          {activeView === "tips" && <SafetyTips selectedAge={selectedAge} />}
        </div>

        {/* Stats Footer - Mobile optimized */}
        <div className="mt-8 sm:mt-12 bg-white rounded-lg shadow-sm p-4 sm:p-6">
          <div className="grid grid-cols-3 gap-3 sm:gap-6 text-center">
            <div>
              <div className="text-xl sm:text-2xl font-bold text-blue-600">67%</div>
              <div className="text-xs sm:text-sm text-gray-600">of injuries occur at home</div>
            </div>
            <div>
              <div className="text-xl sm:text-2xl font-bold text-green-600">85%</div>
              <div className="text-xs sm:text-sm text-gray-600">are preventable</div>
            </div>
            <div>
              <div className="text-xl sm:text-2xl font-bold text-orange-600">2.3M</div>
              <div className="text-xs sm:text-sm text-gray-600">
                <span className="hidden sm:inline">annual ER visits prevented</span>
                <span className="sm:hidden">ER visits prevented</span>
              </div>
            </div>
          </div>
        </div>
      </main>
    </div>
  );
};

export default Index;
