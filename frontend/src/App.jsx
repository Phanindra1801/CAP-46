
import './App.css';

function App() {
  const services = [
    {
      name: 'React Frontend',
      description: 'User interface and static asset delivery.',
      status: 'Running',
      type: 'Frontend',
    },
    {
      name: 'Nginx Reverse Proxy',
      description: 'Incoming request routing and traffic management.',
      status: 'Not configured',
      type: 'Proxy',
    },
    {
      name: 'Spring Boot Backend',
      description: 'REST APIs and application business logic.',
      status: 'Not configured',
      type: 'Backend',
    },
  ];

  return (
    <div className="app">
      <header className="navbar">
        <div className="brand">
          <span className="brand-icon">C</span>
          <span>CAP-46</span>
        </div>

        <nav>
          <a href="#overview">Overview</a>
          <a href="#services">Services</a>
          <a href="#architecture">Architecture</a>
        </nav>

        <span className="environment">LOCAL DEVELOPMENT</span>
      </header>

      <main>
        <section className="hero" id="overview">
          <p className="eyebrow">REVERSE PROXY MANAGEMENT</p>

          <h1>
            Nginx Reverse-Proxy
            <br />
            <span>Failure Isolation</span>
          </h1>

          <p className="hero-description">
            A controlled deployment environment for application
            routing, service monitoring, configuration validation,
            and safe rollback.
          </p>

          <a className="primary-button" href="#services">
            Explore services →
          </a>
        </section>

        <section className="services-section" id="services">
          <div className="section-heading">
            <div>
              <p className="eyebrow">SYSTEM OVERVIEW</p>
              <h2>Application Services</h2>
            </div>

            <span className="service-count">
              {services.length} services
            </span>
          </div>

          <div className="service-grid">
            {services.map((service) => (
              <article className="service-card" key={service.name}>
                <span className="service-type">{service.type}</span>

                <h3>{service.name}</h3>

                <p>{service.description}</p>

                <div className="service-status">
                  <span
                    className={
                      service.status === 'Running'
                        ? 'status-dot active'
                        : 'status-dot pending'
                    }
                  />

                  {service.status}
                </div>
              </article>
            ))}
          </div>
        </section>

        <section className="architecture-section" id="architecture">
          <p className="eyebrow">REQUEST FLOW</p>
          <h2>How the application works</h2>

          <div className="flow">
            <div className="flow-item">Browser</div>
            <span>→</span>
            <div className="flow-item">Nginx</div>
            <span>→</span>
            <div className="flow-item">React / Spring Boot</div>
          </div>

          <p className="flow-description">
            Nginx will route frontend requests to the React
            application and API requests to Spring Boot.
          </p>
        </section>
      </main>

      <footer>
        CAP-46 · Nginx Reverse-Proxy Failure Isolation
        <span>Development environment</span>
      </footer>
    </div>
  );
}

export default App;
