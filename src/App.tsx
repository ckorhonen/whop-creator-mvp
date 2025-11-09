import { useState } from 'react'
import './App.css'

function App() {
  const [count, setCount] = useState(0)

  return (
    <div className="app">
      <header>
        <h1>🚀 Creator Economy MVP</h1>
        <p>Built with React + TypeScript for Whop</p>
      </header>
      
      <main>
        <div className="card">
          <button onClick={() => setCount((count) => count + 1)}>
            Count: {count}
          </button>
          <p>Ready to build your creator platform</p>
        </div>
      </main>

      <footer>
        <p>Deployed on Cloudflare Workers</p>
      </footer>
    </div>
  )
}

export default App