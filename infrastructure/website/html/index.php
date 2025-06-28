<?php
// Database configuration
$db_host = 'localhost:3307';
$db_name = 'grieftodesign';
$db_user = 'griefweb';
$db_pass = 'secure_password_2024!';

try {
    $pdo = new PDO("mysql:host=$db_host;dbname=$db_name", $db_user, $db_pass);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
} catch(PDOException $e) {
    // Database connection failed - continue without it
    $pdo = null;
}

// Newsletter signup handling
if ($_POST['action'] ?? '' === 'newsletter' && $pdo) {
    $email = filter_var($_POST['email'] ?? '', FILTER_VALIDATE_EMAIL);
    if ($email) {
        try {
            // Create table if it doesn't exist
            $pdo->exec("CREATE TABLE IF NOT EXISTS newsletter_signups (
                id INT AUTO_INCREMENT PRIMARY KEY,
                email VARCHAR(255) UNIQUE NOT NULL,
                signup_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                ip_address VARCHAR(45),
                user_agent TEXT
            )");
            
            $stmt = $pdo->prepare("INSERT INTO newsletter_signups (email, ip_address, user_agent) VALUES (?, ?, ?)");
            $stmt->execute([$email, $_SERVER['REMOTE_ADDR'] ?? '', $_SERVER['HTTP_USER_AGENT'] ?? '']);
            $newsletter_message = "Thank you for joining our mission to expose pharmaceutical corruption!";
        } catch(PDOException $e) {
            $newsletter_message = "Email already registered or error occurred.";
        }
    } else {
        $newsletter_message = "Please enter a valid email address.";
    }
}
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Grieftodesign - Transforming Loss into Systemic Change</title>
    <meta name="description" content="Exposing pharmaceutical corruption and drug policy deception. Evidence-based research showing how illegality creates danger while safe natural treatments are suppressed for profit.">
    <meta name="keywords" content="pharmaceutical corruption, drug policy reform, cannabis safety, GHB Xyrem, FDA revolving door, natural medicine suppression">
    
    <!-- Open Graph -->
    <meta property="og:title" content="Grieftodesign - The Truth About Drug Safety">
    <meta property="og:description" content="Cannabis: 0 deaths. Alcohol: 88,000 deaths annually. Why is the safer one criminalized? Follow the money.">
    <meta property="og:type" content="website">
    <meta property="og:url" content="https://grieftodesign.org">
    
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            font-family: 'Georgia', serif;
            line-height: 1.6;
            color: #333;
            background: linear-gradient(135deg, #1e3c72 0%, #2a5298 100%);
            min-height: 100vh;
        }
        
        .container {
            max-width: 1200px;
            margin: 0 auto;
            padding: 0 20px;
        }
        
        header {
            background: rgba(0, 0, 0, 0.9);
            color: white;
            padding: 1rem 0;
            position: fixed;
            width: 100%;
            top: 0;
            z-index: 1000;
            backdrop-filter: blur(10px);
        }
        
        nav {
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        
        .logo {
            font-size: 1.5rem;
            font-weight: bold;
            color: #ffd700;
        }
        
        .nav-links {
            display: flex;
            list-style: none;
            gap: 2rem;
        }
        
        .nav-links a {
            color: white;
            text-decoration: none;
            transition: color 0.3s;
        }
        
        .nav-links a:hover {
            color: #ffd700;
        }
        
        main {
            margin-top: 80px;
            padding: 2rem 0;
        }
        
        .hero {
            background: rgba(255, 255, 255, 0.95);
            border-radius: 10px;
            padding: 3rem 2rem;
            margin: 2rem 0;
            text-align: center;
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.3);
        }
        
        .hero h1 {
            font-size: 2.5rem;
            margin-bottom: 1rem;
            color: #1e3c72;
        }
        
        .hero .subtitle {
            font-size: 1.2rem;
            color: #666;
            margin-bottom: 2rem;
        }
        
        .shock-stat {
            background: #ff4444;
            color: white;
            padding: 1rem;
            border-radius: 5px;
            margin: 1rem 0;
            font-size: 1.1rem;
            font-weight: bold;
        }
        
        .content-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
            gap: 2rem;
            margin: 2rem 0;
        }
        
        .content-card {
            background: rgba(255, 255, 255, 0.95);
            padding: 2rem;
            border-radius: 10px;
            box-shadow: 0 5px 15px rgba(0, 0, 0, 0.2);
        }
        
        .content-card h3 {
            color: #1e3c72;
            margin-bottom: 1rem;
            font-size: 1.3rem;
        }
        
        .evidence-table {
            width: 100%;
            border-collapse: collapse;
            margin: 1rem 0;
        }
        
        .evidence-table th,
        .evidence-table td {
            border: 1px solid #ddd;
            padding: 0.5rem;
            text-align: left;
        }
        
        .evidence-table th {
            background: #1e3c72;
            color: white;
        }
        
        .evidence-table tr:nth-child(even) {
            background: #f9f9f9;
        }
        
        .cta-section {
            background: rgba(255, 255, 255, 0.95);
            padding: 3rem 2rem;
            border-radius: 10px;
            margin: 2rem 0;
            text-align: center;
        }
        
        .newsletter-form {
            display: flex;
            max-width: 400px;
            margin: 1rem auto;
            gap: 0.5rem;
        }
        
        .newsletter-form input[type="email"] {
            flex: 1;
            padding: 0.75rem;
            border: 1px solid #ddd;
            border-radius: 5px;
            font-size: 1rem;
        }
        
        .btn {
            background: #1e3c72;
            color: white;
            padding: 0.75rem 1.5rem;
            border: none;
            border-radius: 5px;
            cursor: pointer;
            text-decoration: none;
            display: inline-block;
            transition: background 0.3s;
            font-size: 1rem;
        }
        
        .btn:hover {
            background: #2a5298;
        }
        
        .btn-danger {
            background: #ff4444;
        }
        
        .btn-danger:hover {
            background: #cc0000;
        }
        
        .social-proof {
            background: rgba(255, 255, 255, 0.95);
            padding: 2rem;
            border-radius: 10px;
            margin: 2rem 0;
        }
        
        .quote {
            font-style: italic;
            font-size: 1.1rem;
            border-left: 4px solid #1e3c72;
            padding-left: 1rem;
            margin: 1rem 0;
        }
        
        footer {
            background: rgba(0, 0, 0, 0.9);
            color: white;
            text-align: center;
            padding: 2rem 0;
            margin-top: 3rem;
        }
        
        .success-message {
            background: #4CAF50;
            color: white;
            padding: 1rem;
            border-radius: 5px;
            margin: 1rem 0;
        }
        
        @media (max-width: 768px) {
            .nav-links {
                flex-direction: column;
                gap: 1rem;
            }
            
            .hero h1 {
                font-size: 2rem;
            }
            
            .newsletter-form {
                flex-direction: column;
            }
        }
    </style>
</head>
<body>
    <header>
        <nav class="container">
            <div class="logo">GriefToDesign</div>
            <ul class="nav-links">
                <li><a href="#evidence">Evidence</a></li>
                <li><a href="#research">Research</a></li>
                <li><a href="#action">Take Action</a></li>
                <li><a href="#about">About</a></li>
            </ul>
        </nav>
    </header>

    <main class="container">
        <section class="hero">
            <h1>The Truth About Drug Safety</h1>
            <p class="subtitle">How pharmaceutical corruption created the most dangerous drug policy lie in history</p>
            
            <div class="shock-stat">
                Cannabis: 0 overdose deaths in recorded history<br>
                Alcohol: 88,000 deaths annually in the US<br>
                <strong>Why is the safer one criminalized?</strong>
            </div>
            
            <p><strong>Follow the money.</strong> The pharmaceutical industry cannot patent cannabis, so they've spent billions ensuring it remains illegal while they sell synthetic alternatives at 100x the cost.</p>
            
            <a href="#evidence" class="btn btn-danger">See The Evidence</a>
        </section>

        <section id="evidence" class="content-grid">
            <div class="content-card">
                <h3>🚨 The Cannabis Paradox</h3>
                <p>The US Government owns <strong>Patent #6630507</strong> acknowledging cannabis as medicine, while simultaneously maintaining it's Schedule I - "no medical value."</p>
                <div class="quote">
                    "Marijuana is one of the safest therapeutically active substances known to man."
                    <br><em>- DEA Judge Francis Young, 1988</em>
                </div>
            </div>

            <div class="content-card">
                <h3>💰 The GHB/Xyrem Scandal</h3>
                <p><strong>Same molecule. Two legal statuses. 3,750x price difference.</strong></p>
                <ul>
                    <li>GHB: Schedule I, felony possession</li>
                    <li>Xyrem: Schedule III, $75,000/year prescription</li>
                    <li>Production cost: Pennies per dose</li>
                    <li>Jazz Pharmaceuticals revenue: $1.8 billion annually</li>
                </ul>
            </div>

            <div class="content-card">
                <h3>🔄 FDA Revolving Door</h3>
                <p><strong>65%</strong> of FDA officials join pharmaceutical companies within 5 years of leaving office.</p>
                <p><strong>45%</strong> of pharmaceutical executives previously worked at the FDA.</p>
                <p>This isn't coincidence. It's systematic regulatory capture.</p>
            </div>
        </section>

        <section class="content-card">
            <h3>📊 The Real Safety Data</h3>
            <table class="evidence-table">
                <thead>
                    <tr>
                        <th>Substance</th>
                        <th>Legal Status</th>
                        <th>Annual Deaths (US)</th>
                        <th>Safety Margin</th>
                    </tr>
                </thead>
                <tbody>
                    <tr>
                        <td>Tobacco</td>
                        <td>Legal</td>
                        <td>480,000</td>
                        <td>3:1</td>
                    </tr>
                    <tr>
                        <td>Alcohol</td>
                        <td>Legal</td>
                        <td>88,000</td>
                        <td>10:1</td>
                    </tr>
                    <tr>
                        <td>Prescription Opioids</td>
                        <td>Legal</td>
                        <td>70,000</td>
                        <td>Variable</td>
                    </tr>
                    <tr style="background: #ffeeee;">
                        <td>Cannabis</td>
                        <td>Illegal</td>
                        <td>0 (direct)</td>
                        <td>>10,000:1</td>
                    </tr>
                    <tr style="background: #ffeeee;">
                        <td>Psilocybin</td>
                        <td>Illegal</td>
                        <td><5 (all time)</td>
                        <td>1000:1</td>
                    </tr>
                    <tr style="background: #ffeeee;">
                        <td>LSD</td>
                        <td>Illegal</td>
                        <td><5 (all time)</td>
                        <td>1000:1</td>
                    </tr>
                </tbody>
            </table>
            <p><strong>Legal substances cause 99.99% of substance-related deaths.</strong></p>
        </section>

        <section class="social-proof">
            <h3>🎯 International Evidence</h3>
            <div class="content-grid">
                <div>
                    <h4>Portugal (Decriminalization)</h4>
                    <ul>
                        <li>95% reduction in drug-related crime</li>
                        <li>85% decrease in HIV infections</li>
                        <li>4 overdose deaths per million (lowest in Europe)</li>
                    </ul>
                </div>
                <div>
                    <h4>United States (Prohibition)</h4>
                    <ul>
                        <li>220 overdose deaths per million (highest globally)</li>
                        <li>2.3 million people incarcerated</li>
                        <li>68% recidivism rate</li>
                    </ul>
                </div>
            </div>
        </section>

        <section id="research" class="content-card">
            <h3>📚 Research Documentation</h3>
            <p>Our research compilation includes over 200 citations from peer-reviewed journals, government documents, and industry insider testimony exposing:</p>
            <ul>
                <li>How DMSO cancer treatment was suppressed despite proven effectiveness</li>
                <li>Why IV Vitamin C research was buried after National Cancer Institute confirmed it works</li>
                <li>The systematic suppression of natural treatments that threaten pharmaceutical profits</li>
                <li>International pressure campaigns to export US drug war globally</li>
            </ul>
            <a href="/research" class="btn">Access Full Research</a>
        </section>

        <section id="action" class="cta-section">
            <h2>🚀 Take Action</h2>
            <p>Every person denied access to safe, effective treatments is a victim of pharmaceutical corruption. Every family destroyed by drug laws is collateral damage in a profit protection scheme.</p>
            
            <div class="content-grid">
                <div>
                    <h4>📧 Join Our Email Campaign</h4>
                    <p>Get the evidence that exposes pharmaceutical corruption and demand evidence-based policy.</p>
                    
                    <?php if (isset($newsletter_message)): ?>
                        <div class="success-message"><?= htmlspecialchars($newsletter_message) ?></div>
                    <?php endif; ?>
                    
                    <form method="POST" class="newsletter-form">
                        <input type="hidden" name="action" value="newsletter">
                        <input type="email" name="email" placeholder="Your email address" required>
                        <button type="submit" class="btn">Join Campaign</button>
                    </form>
                </div>
                
                <div>
                    <h4>📞 Contact Representatives</h4>
                    <p>Demand investigation into FDA-pharmaceutical revolving door and rescheduling based on actual safety data.</p>
                    <a href="/action-templates" class="btn">Get Templates</a>
                </div>
            </div>
        </section>

        <section id="about" class="content-card">
            <h3>🎯 About GriefToDesign</h3>
            <div class="quote">
                "We start again — not from zero, but from loss."
            </div>
            <p>This project emerged from personal tragedy and the recognition that most preventable suffering stems from systems designed to prioritize profit over human wellbeing.</p>
            
            <p><strong>Our framework:</strong></p>
            <ul>
                <li><strong>People are good.</strong> Systems are broken. We can fix the systems.</li>
                <li><strong>Trust-first governance</strong> over paternalistic control</li>
                <li><strong>Abundance over artificial scarcity</strong></li>
                <li><strong>Evidence over propaganda</strong></li>
            </ul>
            
            <p>Every preventable tragedy should catalyze system transformation. We have the resources and evidence to build differently.</p>
        </section>
    </main>

    <footer>
        <div class="container">
            <p>&copy; 2025 GriefToDesign. Licensed under Creative Commons Attribution 4.0.</p>
            <p>Transform loss into systemic change. Build systems that prioritize human wellbeing over corporate profits.</p>
        </div>
    </footer>

    <script>
        // Smooth scrolling for navigation links
        document.querySelectorAll('a[href^="#"]').forEach(anchor => {
            anchor.addEventListener('click', function (e) {
                e.preventDefault();
                const target = document.querySelector(this.getAttribute('href'));
                if (target) {
                    target.scrollIntoView({
                        behavior: 'smooth',
                        block: 'start'
                    });
                }
            });
        });

        // Add animation on scroll
        const observerOptions = {
            threshold: 0.1,
            rootMargin: '0px 0px -50px 0px'
        };

        const observer = new IntersectionObserver((entries) => {
            entries.forEach(entry => {
                if (entry.isIntersecting) {
                    entry.target.style.opacity = '1';
                    entry.target.style.transform = 'translateY(0)';
                }
            });
        }, observerOptions);

        // Apply fade-in animation to content cards
        document.querySelectorAll('.content-card, .hero, .cta-section').forEach(el => {
            el.style.opacity = '0';
            el.style.transform = 'translateY(20px)';
            el.style.transition = 'opacity 0.6s ease, transform 0.6s ease';
            observer.observe(el);
        });
    </script>
</body>
</html>
