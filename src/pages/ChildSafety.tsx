import AgeSelector from "../components/AgeSelector";
import RiskMatrix from "../components/RiskMatrix";
import RoomAssessment from "../components/RoomAssessment";
import SafetyTips from "../components/SafetyTips";

const ChildSafety = () => {
  return (
    <div className="space-y-6">
      <div className="text-center mb-8">
        <h1 className="text-4xl font-bold text-gray-800 mb-4">
          Home Safety Matrix AI
        </h1>
        <p className="text-lg text-gray-600">
          Comprehensive child safety assessment and guidance system
        </p>
      </div>
      
      <AgeSelector />
      <RiskMatrix />
      <RoomAssessment />
      <SafetyTips />
    </div>
  );
};

export default ChildSafety;
