import { StrictMode } from "react";
import { hydrateRoot } from "react-dom/client";
import App from "./App";
import "./index.css";

// The markup in #root comes from scripts/prerender.ts; hydrate in place.
hydrateRoot(
  document.getElementById("root")!,
  <StrictMode>
    <App />
  </StrictMode>,
);
