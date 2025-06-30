import React from "react";
import { Link } from "react-router-dom";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";

const Home = () => {
  return (
    <div className="space-y-12">
      {/* Hero Section */}
      <div className="text-center space-y-6">
        <h1 className="text-5xl font-bold text-gray-900 leading-tight">
          GriefToDesign
        </h1>
        <p className="text-2xl text-gray-600 max-w-3xl mx-auto">
          "We start again — not from zero, but from loss. And we build something so beautiful that future grief becomes unnecessary."
        </p>
        <div className="flex gap-4 justify-center">
          <Link to="/child-safety">
            <Button size="lg" className="text-lg px-8 py-3">
              Try Child Safety Matrix
            </Button>
          </Link>
          <Link to="/overview">
            <Button variant="outline" size="lg" className="text-lg px-8 py-3">
              Learn About Our Vision
            </Button>
          </Link>
        </div>
      </div>

      {/* Mission Statement */}
      <div className="bg-white rounded-lg p-8 shadow-lg">
        <h2 className="text-3xl font-bold text-gray-900 mb-6 text-center">
          Our Mission
        </h2>
        <p className="text-lg text-gray-700 leading-relaxed max-w-4xl mx-auto text-center">
          Transform grief into systemic change that makes future grief unnecessary. 
          Through comprehensive research, innovative design, and evidence-based solutions, 
          we're building systems that address root causes rather than symptoms.
        </p>
      </div>

      {/* Key Features */}
      <div className="grid md:grid-cols-3 gap-6">
        <Card>
          <CardHeader>
            <CardTitle className="text-xl">Child Safety Matrix</CardTitle>
            <CardDescription>
              AI-powered home safety assessment and guidance system
            </CardDescription>
          </CardHeader>
          <CardContent>
            <p className="text-gray-600 mb-4">
              Comprehensive child safety tools that help families create safer environments 
              through age-appropriate assessments and personalized recommendations.
            </p>
            <Link to="/child-safety">
              <Button variant="outline" className="w-full">
                Explore Safety Tools
              </Button>
            </Link>
          </CardContent>
        </Card>

        <Card>
          <CardHeader>
            <CardTitle className="text-xl">Research & Analysis</CardTitle>
            <CardDescription>
              Evidence-based approaches to systemic change
            </CardDescription>
          </CardHeader>
          <CardContent>
            <p className="text-gray-600 mb-4">
              Comprehensive research across domains including education, drug policy, 
              universal income, and infrastructure design.
            </p>
            <Link to="/research">
              <Button variant="outline" className="w-full">
                View Research
              </Button>
            </Link>
          </CardContent>
        </Card>

        <Card>
          <CardHeader>
            <CardTitle className="text-xl">The $19T Solution</CardTitle>
            <CardDescription>
              Complete blueprint for systemic transformation
            </CardDescription>
          </CardHeader>
          <CardContent>
            <p className="text-gray-600 mb-4">
              A comprehensive plan for transforming society through abundance-based 
              governance and universal resource allocation.
            </p>
            <Link to="/overview">
              <Button variant="outline" className="w-full">
                Learn More
              </Button>
            </Link>
          </CardContent>
        </Card>
      </div>

      {/* Call to Action */}
      <div className="bg-gradient-to-r from-blue-600 to-purple-600 rounded-lg p-8 text-white text-center">
        <h2 className="text-3xl font-bold mb-4">
          Join Us in Building a Better Future
        </h2>
        <p className="text-xl mb-6 opacity-90">
          Every child deserves to grow up and become everything they could be.
        </p>
        <Link to="/contact">
          <Button size="lg" variant="secondary" className="text-lg px-8 py-3">
            Get Involved
          </Button>
        </Link>
      </div>
    </div>
  );
};

export default Home;
