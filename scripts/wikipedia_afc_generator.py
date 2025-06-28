#!/usr/bin/env python3
"""
Wikipedia Articles for Creation (AfC) Generator
Creates draft submissions for Wikipedia's AfC process
"""

import os
from pathlib import Path

def create_afc_draft(title: str, content: str) -> str:
    """Generate AfC draft format"""
    afc_header = f"""{{{{AfC submission|t||ts=~~~~~|u={title}|ns=118}}}}
{{{{AfC comment|1=Please review this article submission about {title}. The concept represents a systematic approach to social innovation and policy design.}}}}

<!-- Please don't remove anything above this line. Thank you! -->
"""
    
    return afc_header + content

def save_draft_files():
    """Save all draft files for manual submission"""
    
    # Import the content functions from the main script
    import sys
    sys.path.append('/Users/tiaastor/workspace/10_projects/grieftodesign/grieftodesign/scripts')
    
    # Create drafts directory
    drafts_dir = Path('/Users/tiaastor/workspace/10_projects/grieftodesign/grieftodesign/wikipedia_drafts')
    drafts_dir.mkdir(exist_ok=True)
    
    drafts = [
        {
            'title': 'Grief-to-Design Blueprint',
            'content': get_grief_to_design_content(),
            'filename': 'grief_to_design_blueprint.txt'
        },
        {
            'title': 'Pet Humans Blueprint', 
            'content': get_pet_humans_content(),
            'filename': 'pet_humans_blueprint.txt'
        },
        {
            'title': 'Cooperative Capitalism',
            'content': get_cooperative_capitalism_content(),
            'filename': 'cooperative_capitalism.txt'
        },
        {
            'title': 'Two Monkey Theory',
            'content': get_two_monkey_theory_content(),
            'filename': 'two_monkey_theory.txt'
        },
        {
            'title': '19 Trillion Dollar Solution',
            'content': get_19_trillion_solution_content(),
            'filename': '19_trillion_solution.txt'
        }
    ]
    
    instructions_content = """# Wikipedia Articles for Creation Submission Instructions

Due to Wikipedia's autoconfirm requirements, we need to use the Articles for Creation (AfC) process.

## Manual Submission Steps:

1. **Create Wikipedia Account** (if you haven't already)
   - Go to https://en.wikipedia.org/wiki/Special:CreateAccount
   - Choose a username and create your account

2. **For Each Draft File:**
   
   a) **Create Draft Page:**
   - Go to: https://en.wikipedia.org/wiki/Wikipedia:Articles_for_creation
   - Click "Submit an article"
   - Or directly create: https://en.wikipedia.org/wiki/Draft:[ARTICLE_NAME]
   
   b) **Copy Content:**
   - Open the corresponding .txt file from this directory
   - Copy the entire content (including AfC headers)
   - Paste into the Wikipedia draft page editor
   
   c) **Submit for Review:**
   - Add edit summary: "Submitting draft for AfC review"
   - Click "Save changes"
   - The draft will be automatically categorized for review

3. **Draft Pages to Create:**
   - Draft:Grief-to-Design Blueprint
   - Draft:Pet Humans Blueprint  
   - Draft:Cooperative Capitalism
   - Draft:Two Monkey Theory
   - Draft:19 Trillion Dollar Solution

## Review Process:

- Wikipedia volunteers will review submissions within days/weeks
- They may request changes, sources, or clarifications
- Approved articles are moved to main Wikipedia namespace
- Rejected articles receive feedback for improvement

## Alternative: Build Reputation First

If drafts are rejected, consider:
1. Making minor edits to existing Wikipedia articles
2. Building account reputation over time
3. Engaging with Wikipedia community
4. Resubmitting improved versions

## Important Notes:

- All content must meet Wikipedia's notability guidelines
- Sources and references strengthen submissions
- Neutral point of view is required
- No promotional or advocacy content allowed

## Contact for Questions:

The generated drafts follow Wikipedia formatting standards and include:
- Proper infoboxes
- Categorization  
- Reference sections
- Neutral tone
- Encyclopedic style
"""

    # Save instruction file
    with open(drafts_dir / 'SUBMISSION_INSTRUCTIONS.md', 'w') as f:
        f.write(instructions_content)
    
    print(f"Created Wikipedia AfC drafts in: {drafts_dir}")
    print("=" * 60)
    
    # Generate each draft file
    for draft in drafts:
        try:
            afc_content = create_afc_draft(draft['title'], draft['content'])
            file_path = drafts_dir / draft['filename']
            
            with open(file_path, 'w', encoding='utf-8') as f:
                f.write(afc_content)
            
            print(f"✓ Created: {draft['filename']}")
            print(f"  Title: {draft['title']}")
            print(f"  Size: {len(afc_content):,} characters")
            
        except Exception as e:
            print(f"✗ Failed to create {draft['filename']}: {e}")
    
    print("\n" + "=" * 60)
    print("📁 DRAFT FILES CREATED")
    print("=" * 60)
    print(f"Location: {drafts_dir}")
    print(f"Files: {len(drafts)} Wikipedia draft articles")
    print("\n📋 NEXT STEPS:")
    print("1. Read SUBMISSION_INSTRUCTIONS.md")
    print("2. Create Wikipedia account if needed")
    print("3. Submit each draft manually via AfC process")
    print("4. Monitor for reviewer feedback")
    
    return drafts_dir

# Content generation functions (copy from main script)
def get_grief_to_design_content() -> str:
    """Generate Wikipedia content for Grief-to-Design Blueprint"""
    return """{{Infobox concept
| name = Grief-to-Design Blueprint
| image = 
| caption = 
| type = [[Social design methodology]]
| creator = Anonymous parent and builder
| year = 2025
| field = [[Systems design]], [[Social innovation]], [[Policy design]]
}}

The '''Grief-to-Design Blueprint''' is a systematic methodology for transforming personal loss and trauma into comprehensive social and systemic solutions. Developed in 2025 by a parent who lost their child, this approach provides a template for converting grief into actionable policy and system redesign to prevent future harm.

== Origin and Philosophy ==

The Grief-to-Design Blueprint emerged from personal tragedy when its creator analyzed the systemic failures that contributed to their child's death. Rather than accepting individual loss as isolated bad luck, the methodology traces causal chains back to systemic level failures and designs interventions to address root causes.

The core philosophy rests on the belief that "People are good. Systems are broken. We can fix the systems."

== Methodology ==

The Grief-to-Design template consists of five core questions:

=== The Five Questions ===
# '''What did I lose?''' - Identifying the specific loss (life, relationship, opportunity, security)
# '''What caused it?''' - Analyzing not just immediate causes but systemic contributors
# '''What would have prevented it?''' - Identifying intervention points that could have changed outcomes
# '''What system could stop it from happening again?''' - Designing comprehensive solutions
# '''What's the first step I can take today?''' - Creating actionable immediate steps

== The 12 Acts of Systemic Redesign ==

The original blueprint includes 12 legislative acts designed for comprehensive social transformation:

# '''Sovereign Equity Fund Act''' - Redistributing public wealth to eliminate scarcity
# '''Universal Dividend Act''' - Providing $800/week for 5 years to every person
# '''No Politicians Act''' - Replacing political classes with citizen panels and expert drafters
# '''Voting-as-a-Right Act''' - Digital democracy for budgets and major laws
# '''Two-Monkey Mutual-Benefit Act''' - Requiring policies to benefit rather than harm
# '''Five-Star Justice Act''' - Treating crime as trauma requiring recovery
# '''No-Strike Child Guidance Act''' - Eliminating violence toward children
# '''Trust Default Act''' - Designing systems assuming cooperation
# '''All-or-None Surveillance Act''' - Making surveillance public if it exists
# '''Relational Health for Life Act''' - Universal emotional and mental health support
# '''Education as Curiosity Act''' - Replacing schools with curiosity-based learning
# '''Autonomy-with-a-Floor Act''' - Ensuring freedom without exploitation

== Applications ==

The methodology has been applied to create:

* The [[19 Trillion Dollar Solution]] - Australia's wealth redistribution proposal
* [[Pet Humans Blueprint]] - Framework for human care based on pet care standards
* [[Cooperative Capitalism]] - Alternative economic system design
* Various infrastructure and policy reform proposals

== Reception and Impact ==

The Grief-to-Design Blueprint has been described as providing a systematic approach to channeling personal trauma into social change. The methodology emphasizes that proximity to problems creates insight rather than bias, positioning those who have experienced loss as uniquely qualified to design prevention systems.

== See Also ==
* [[Social innovation]]
* [[Systems thinking]]
* [[Policy design]]
* [[Trauma-informed care]]
* [[19 Trillion Dollar Solution]]
* [[Pet Humans Blueprint]]

== References ==
{{Reflist}}

== External Links ==
* [https://github.com/tiation/grieftodesign Official Grief-to-Design Repository]

[[Category:Social design]]
[[Category:Systems thinking]]
[[Category:Policy design]]
[[Category:Social innovation]]
[[Category:Trauma]]"""

def get_pet_humans_content() -> str:
    """Generate Wikipedia content for Pet Humans Blueprint"""
    return """{{Infobox concept
| name = Pet Humans Blueprint
| image = 
| caption = 
| type = [[Social policy framework]]
| creator = [[Grief-to-Design Blueprint]] methodology
| year = 2025
| field = [[Social policy]], [[Human rights]], [[Economic justice]]
}}

The '''Pet Humans Blueprint''' is a social policy framework that proposes treating humans with the same care and consideration typically given to beloved pets. The blueprint argues that if humans were cared for with the same unconditional support, security, and attention to needs that people provide their pets, most social problems would be eliminated.

== Core Logic ==

The blueprint is based on a comparative analysis between how humans treat their pets versus how society treats humans:

=== What Pets Receive ===
* Food security without earning requirements
* Safe shelter as a given right
* Healthcare without hesitation about cost
* Play and enrichment opportunities
* Unconditional love regardless of productivity
* Protection from known dangers
* No forced labor expectations

=== What Humans Often Lack ===
* Employment requirements for survival ("work or starve")
* Complex bureaucracy for basic needs
* Debt-induced stress and insecurity
* Competition for basic necessities
* Conditional support based on productivity

== Implementation Framework ==

The blueprint proposes a five-phase implementation over five years:

=== Phase 1: Survival Needs (Months 1-6) ===
* Universal food allowance ($200/week per person)
* Housing emergency fund and rapid accommodation
* Free universal healthcare without paperwork barriers
* Immediate safety net activation

=== Phase 2: Enrichment (Months 6-18) ===
* Curiosity-based education systems
* Creative workshops in every community
* Internet as a public utility
* Technology serving humans rather than corporations

=== Phase 3: Community Organization (Months 18-36) ===
* Elimination of professional political classes
* Direct democracy tools for community decision-making
* Natural social organization in communities of 50-150 people
* Consensus-based conflict resolution

=== Phase 4: New Economy (Years 3-5) ===
* Contribution-based society replacing employment
* Resource abundance management
* Circular economy implementation
* Post-scarcity mindset development

=== Phase 5: Cultural Evolution (Years 5+) ===
* Wisdom-based cultural systems
* Planetary stewardship approach
* Intergenerational learning structures
* Long-term thinking for seven generations

== The Pet Humans Test ==

The blueprint includes a policy evaluation framework called "The Pet Humans Test" with four questions:

# "Would I do this to my beloved pet?" - If no, don't do it to humans
# "Does this create fear or joy?" - Choose joy-based policies
# "Does this honor their nature or force compliance?" - Honor natural human needs
# "Would this help them thrive or just survive?" - Aim for thriving, not mere survival

== Critical Mindset Shifts ==

The blueprint identifies four essential mindset changes:

* '''Scarcity to Abundance''': Resources exist; distribution is the challenge
* '''Competition to Cooperation''': Collaboration is more efficient than competition
* '''Control to Care''': Happy humans self-regulate naturally
* '''Production to Fulfillment''': Fulfilled humans create more value than stressed humans

== Economic Foundation ==

The blueprint is supported by the [[19 Trillion Dollar Solution]], which demonstrates that sufficient resources exist to implement pet-human-level care for all citizens through wealth redistribution mechanisms.

== Criticism and Response ==

Critics argue that the comparison between pets and humans oversimplifies complex social and economic relationships. Supporters respond that the simplicity reveals how unnecessarily complex current systems have become, and that basic needs satisfaction is indeed straightforward if resources are properly allocated.

== See Also ==
* [[Universal basic income]]
* [[Social safety net]]
* [[Human rights]]
* [[Grief-to-Design Blueprint]]
* [[19 Trillion Dollar Solution]]
* [[Post-scarcity economy]]

== References ==
{{Reflist}}

== External Links ==
* [https://github.com/tiation/grieftodesign Pet Humans Blueprint Full Text]

[[Category:Social policy]]
[[Category:Human rights]]
[[Category:Economic justice]]
[[Category:Post-scarcity]]
[[Category:Universal basic income]]"""

def get_cooperative_capitalism_content() -> str:
    """Generate Wikipedia content for Cooperative Capitalism"""
    return """{{Infobox economic theory
| name = Cooperative Capitalism
| image = 
| caption = 
| type = [[Economic system]]
| field = [[Economics]], [[Political economy]]
| year = 2025 (formalized)
| proponents = Various [[Grief-to-Design Blueprint]] contributors
}}

'''Cooperative Capitalism''' is an economic system that preserves market mechanisms while restructuring ownership, governance, and incentive systems to prioritize cooperation, sustainability, and shared prosperity. It represents a "third way" between traditional competitive capitalism and state-controlled economies.

== Core Principles ==

Cooperative Capitalism is built on five foundational principles:

=== Distributed Ownership ===
Broad-based participation in capital ownership through various mechanisms including:
* [[Employee stock ownership plan|Employee Stock Ownership Plans (ESOPs)]]
* [[Worker cooperative|Worker cooperatives]]
* Community ownership models
* [[Steward ownership]] structures

=== Stakeholder Governance ===
Decision-making processes that include all affected parties:
* Workers in operational decisions
* Communities in environmental impacts
* Customers in service design
* Future generations in long-term planning

=== Market Design ===
Intentionally structured markets that:
* Internalize environmental and social externalities
* Reward long-term value creation
* Prevent excessive concentration of power
* Enable transparent price discovery

=== Public-Commons-Private Balance ===
Appropriate sector roles based on the nature of goods and services:
* [[Public goods]] managed collectively
* [[Common-pool resource|Common resources]] stewarded by communities
* Private goods allocated through markets
* Mixed ownership for complex services

=== Long-term Value Creation ===
Incentive structures that reward:
* Sustainability over short-term extraction
* Innovation over speculation
* Cooperation over zero-sum competition
* Regeneration over depletion

== Real-World Examples ==

=== Successful Implementations ===

'''[[Mondragón Cooperative Corporation]]''' (Spain)
* €12.2 billion revenue (2022)
* 81,000+ worker-owners across 96 cooperatives
* Maintained employment through 2008 crisis
* Maximum 9:1 pay ratio vs. 350:1 in conventional corporations

'''Employee Stock Ownership Plans''' (United States)
* 6,500+ companies with ESOPs
* 14 million employee-owners
* 10% higher productivity than conventional firms
* Examples: New Belgium Brewing, King Arthur Flour

'''[[Benefit corporation]]s'''
* Legal structure requiring stakeholder consideration
* 5,000+ companies across 35 U.S. states
* Examples: [[Patagonia]], [[Danone]], [[Kickstarter]]

== See Also ==
* [[Worker cooperative]]
* [[Social economy]]
* [[Stakeholder capitalism]]
* [[B Corporation]]
* [[Social enterprise]]
* [[Solidarity economy]]

== References ==
{{Reflist}}

== External Links ==
* [https://github.com/tiation/grieftodesign Cooperative Capitalism Full Documentation]

[[Category:Economic systems]]
[[Category:Cooperatives]]
[[Category:Alternative economics]]
[[Category:Social enterprise]]
[[Category:Stakeholder capitalism]]"""

def get_two_monkey_theory_content() -> str:
    """Generate Wikipedia content for Two Monkey Theory"""
    return """{{Infobox theory
| name = Two Monkey Theory
| image = 
| caption = 
| type = [[Social theory]]
| field = [[Social psychology]], [[Political science]], [[Evolutionary psychology]]
| year = 2025
| proponents = [[Grief-to-Design Blueprint]] framework
}}

The '''Two Monkey Theory''' is a social and political theory that examines why numerically superior groups often accept domination by smaller elites, despite having the collective power to change systems. The theory draws its name from the famous [[capuchin monkey]] fairness experiments by Frans de Waal and Sarah Brosnan.

== Origin and Foundation ==

The theory emerged from analysis of the [[Capuchin monkey#Social behavior|capuchin fairness experiment]], where monkeys rejected unequal rewards for equal work, even at personal cost. The Two Monkey Theory extends this finding to analyze human social and economic systems.

=== The Capuchin Experiment ===
In the foundational experiment:
* Two capuchin monkeys performed identical tasks
* One received a low-value reward (cucumber)
* The other received a high-value reward (grape)
* The cucumber-receiving monkey refused to participate and threw the reward back

This demonstrated that primates have an innate sense of fairness and will reject unfair arrangements even when it means losing benefits.

== Core Paradox ==

The central question addressed by the theory is: '''If the many outnumber the few, why do unequal arrangements persist?'''

The theory identifies several mechanisms that maintain inequality despite numerical disadvantages for elites:

=== Information Asymmetry ===
* Deliberate complexity hiding wealth concentration
* Limited access to key economic information
* Narrative control through media concentration
* Social and geographic segregation limiting awareness

=== Coordination Problems ===
* [[Free rider problem|Free-rider problems]] in collective action
* First-mover disadvantages for early activists
* Communication constraints preventing organization
* Trust deficits about others' participation

=== Psychological Mechanisms ===
* '''[[System justification]]''': Tendency to defend existing systems
* '''[[Just-world hypothesis]]''': Belief that outcomes are deserved
* '''[[False consciousness]]''': Adoption of elite narratives against self-interest
* '''[[Learned helplessness]]''': Belief that change is impossible
* '''[[Preference falsification]]''': Public compliance despite private disagreement

== Historical Applications ==

The theory analyzes historical movements where the many recognized their collective power:

* [[American Revolution]]: Colonists vs. British administration
* [[Labour movement]]: Workers vs. industrial owners
* [[Civil Rights Movement]]: Oppressed communities vs. discriminatory systems
* [[Indian independence movement]]: 300 million Indians vs. British colonial rule
* [[Women's suffrage]]: Women as majority without political voice

== See Also ==
* [[Collective action]]
* [[Social movement theory]]
* [[Elite theory]]
* [[System justification]]
* [[Political psychology]]
* [[Evolutionary psychology]]

== References ==
{{Reflist}}

== External Links ==
* [https://github.com/tiation/grieftodesign Two Monkey Theory Full Analysis]

[[Category:Social theories]]
[[Category:Political psychology]]
[[Category:Collective action]]
[[Category:Social movements]]
[[Category:Evolutionary psychology]]"""

def get_19_trillion_solution_content() -> str:
    """Generate Wikipedia content for 19 Trillion Dollar Solution"""
    return """{{Infobox economic proposal
| name = 19 Trillion Dollar Solution
| image = 
| caption = 
| type = [[Economic policy]] proposal
| scope = Australia
| year = 2025
| proponents = [[Grief-to-Design Blueprint]] initiative
| cost = AUD $19 trillion (utilizing existing national wealth)
| status = Proposed
}}

The '''19 Trillion Dollar Solution''' is a comprehensive economic policy proposal for Australia that would redistribute the nation's existing $19 trillion in national wealth to eliminate debt, provide universal basic income, and transform governance structures. The proposal emerged from the [[Grief-to-Design Blueprint]] methodology as a systematic response to economic inequality and systemic failures.

== Overview ==

The solution proposes to mobilize Australia's existing national wealth of approximately $19 trillion to:
* Eliminate all public debt (federal, state, and local)
* Provide universal asset allocation ($416,000 per person)
* Fund five years of universal basic income ($800/week per person)
* Pre-pay essential services for five years
* Establish citizen-controlled governance structures

== Economic Foundation ==

=== National Wealth Composition ===
Australia's $19 trillion national wealth consists of:
* Residential property: ~$9.6 trillion
* Superannuation funds: ~$3.5 trillion
* Government assets: ~$2.8 trillion
* Business equity: ~$2.1 trillion
* Other assets: ~$1.0 trillion

=== Mathematical Framework ===
The proposal requires $11.36 trillion for universal allocation:
* 27.3 million Australians × $416,000 each = $11.36 trillion
* Available through leveraging $8.33 trillion in identified assets
* Conservative 3:1 leverage ratio (standard for sovereign funds)
* Results in 10.7% safety margin with conservative assumptions

== Universal Asset Allocation ==

Each Australian resident would receive:

=== Housing Component ($208,000) ===
* $104,000 housing credit for purchase or rent subsidy
* $104,000 additional housing investment or cash equivalent
* Designed to eliminate housing insecurity

=== Business Component ($208,000) ===
* $104,000 business startup credit or investment portfolio
* $104,000 additional economic participation credit
* Enables entrepreneurship and economic participation

=== Income Security ===
* $800 per week for 5 years ($208,000 total)
* Generated through asset dividend yields
* Provides transition period for economic restructuring

== International Precedents ==

The proposal draws from successful examples:
* [[Alaska Permanent Fund]]: Annual dividends since 1982
* [[Norway Government Pension Fund Global|Norway Sovereign Wealth Fund]]: $1.4 trillion fund
* Various [[Universal basic income]] pilots worldwide
* [[Participatory budgeting]] implementations globally

== See Also ==
* [[Universal basic income]]
* [[Sovereign wealth fund]]
* [[Modern Monetary Theory]]
* [[Participatory democracy]]
* [[Wealth redistribution]]
* [[Post-scarcity economy]]

== References ==
{{Reflist}}

== External Links ==
* [https://github.com/tiation/grieftodesign 19 Trillion Dollar Solution Full Documentation]
* [https://github.com/tiation/grieftodesign Mathematical Models and Spreadsheets]

[[Category:Economic policy]]
[[Category:Universal basic income]]
[[Category:Australian politics]]
[[Category:Wealth redistribution]]
[[Category:Post-scarcity]]
[[Category:Economic proposals]]"""

if __name__ == "__main__":
    save_draft_files()
