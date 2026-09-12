/** Local Magic UI patterns (adapted from potenfyr-nest, CSS-driven, no motion dep). */
import { useEffect, useRef, useState } from "react";

/** Magic UI · Number Ticker: counts up to `value` (rAF, honours reduced motion). */
export function NumberTicker({ value, className }: { value: number; className?: string }) {
  const [display, setDisplay] = useState(0);
  const prev = useRef(0);

  useEffect(() => {
    if (
      typeof document !== "undefined" &&
      (document.hidden || window.matchMedia("(prefers-reduced-motion: reduce)").matches)
    ) {
      prev.current = value;
      setDisplay(value);
      return;
    }
    const from = prev.current;
    const start = performance.now();
    const duration = 900;
    let raf = 0;
    const step = (t: number) => {
      const p = Math.min(1, (t - start) / duration);
      const eased = 1 - Math.pow(1 - p, 3);
      setDisplay(Math.round(from + (value - from) * eased));
      if (p < 1) raf = requestAnimationFrame(step);
      else prev.current = value;
    };
    raf = requestAnimationFrame(step);
    return () => cancelAnimationFrame(raf);
  }, [value]);

  return (
    <span className={className} aria-label={String(value)}>
      {display}
    </span>
  );
}

/** Magic UI · Marquee: seamless infinite scroller (pauses on hover). */
export function Marquee({
  children,
  reverse = false,
  className,
}: {
  children: React.ReactNode;
  reverse?: boolean;
  className?: string;
}) {
  return (
    <div
      className={`group flex w-full overflow-hidden [--duration:35s] [--gap:3rem] [gap:var(--gap)] ${className ?? ""}`}
    >
      {[0, 1].map((i) => (
        <div
          key={i}
          aria-hidden={i === 1}
          style={{
            animation: "mceggs-marquee var(--duration) linear infinite",
            animationDirection: reverse ? "reverse" : "normal",
          }}
          className="flex min-w-full shrink-0 items-center justify-around [gap:var(--gap)] group-hover:[animation-play-state:paused]"
        >
          {children}
        </div>
      ))}
    </div>
  );
}

/** Magic UI · Dot Pattern: decorative dotted backdrop for the hero. */
export function DotPattern({ className }: { className?: string }) {
  return (
    <svg aria-hidden className={`pointer-events-none absolute inset-0 h-full w-full ${className ?? ""}`}>
      <defs>
        <pattern id="mceggs-dots" width="28" height="28" patternUnits="userSpaceOnUse">
          <circle cx="2" cy="2" r="1.2" fill="rgba(139,92,246,0.18)" />
        </pattern>
      </defs>
      <rect width="100%" height="100%" fill="url(#mceggs-dots)" />
    </svg>
  );
}

/** Magic UI · Meteors: streaking comets, hero only. */
export function Meteors({ number = 14 }: { number?: number }) {
  const meteors = Array.from({ length: number }, (_, i) => ({
    id: i,
    left: (i * 137) % 100,
    delay: ((i * 2.3) % 8).toFixed(1),
    dur: (4.5 + ((i * 1.1) % 4)).toFixed(1),
  }));
  return (
    <div aria-hidden className="pointer-events-none absolute inset-0 overflow-hidden">
      {meteors.map((m) => (
        <span
          key={m.id}
          className="absolute h-0.5 w-0.5 rotate-[215deg] rounded-full bg-[#ec4899] shadow-[0_0_0_1px_rgba(236,72,153,0.12)] before:absolute before:top-1/2 before:h-px before:w-20 before:-translate-y-1/2 before:bg-gradient-to-r before:from-[#ec4899] before:to-transparent before:content-['']"
          style={{
            left: `${m.left}%`,
            top: "-8%",
            animation: `meteor-fall ${m.dur}s linear ${m.delay}s infinite`,
          }}
        />
      ))}
    </div>
  );
}

/** Ambient glow orb: hero only (SPEC 5.14). */
export function GlowOrb({
  className,
  color = "rgba(139, 92, 246, 0.18)",
  size = 480,
}: {
  className?: string;
  color?: string;
  size?: number;
}) {
  return (
    <div
      aria-hidden
      className={`pointer-events-none absolute rounded-full blur-[140px] will-change-transform ${className ?? ""}`}
      style={{ width: size, height: size, background: color, animation: "orb-pulse 3s ease-in-out infinite" }}
    />
  );
}
