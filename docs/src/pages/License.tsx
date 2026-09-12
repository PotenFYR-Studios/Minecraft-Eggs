/** /license: plain-language rights under Apache-2.0 with the Commons Clause. */
import { REPO_URL } from "../catalog";
import { DocsShell, PageHeader, type TocItem } from "../components";

const TOC: TocItem[] = [
  { id: "allowed", text: "What you can do", level: 2 },
  { id: "limits", text: "What you cannot do", level: 2 },
  { id: "notice", text: "Attribution and notices", level: 2 },
];

export default function License() {
  return (
    <DocsShell page="license" crumbs={[{ label: "License" }]} toc={TOC}
      prev={{ to: "/about/", title: "About" }}>
      <PageHeader eyebrow="License" title="Free to use," accent="not to sell."
        lead="Minecraft-Eggs ships under Apache-2.0 with the Commons Clause. Here is what that means for you, in plain language." />

      <h2 id="allowed">What you can do</h2>
      <p>
        The egg, its launcher scripts and the universal Docker image are free for any purpose,
        including commercial use. You can:
      </p>
      <ul>
        <li>Fork the repository and modify anything in it.</li>
        <li>Run it on your own hardware or on any panel you operate, for yourself or for others.</li>
        <li>Redistribute the egg or the image, in original or modified form.</li>
        <li>
          Build products and services around it: hosting panels, deployment tools, server
          management, game server businesses.
        </li>
      </ul>

      <h2 id="limits">What you cannot do</h2>
      <p>
        The Commons Clause adds a selling limit on top of Apache-2.0, and Apache-2.0 reserves
        trademarks. You cannot:
      </p>
      <ul>
        <li>Sell the software itself: offering the egg or the image as your paid product.</li>
        <li>
          Charge for a product or service whose value comes entirely or substantially from the
          software&#39;s own functionality.
        </li>
        <li>Use PotenFYR Studios names, logos or trademarks to brand a derivative.</li>
      </ul>
      <p>
        Running a game server hosting company with this egg is fine: your customers pay for
        servers, support and uptime, not for the egg itself.
      </p>

      <h2 id="notice">Attribution and notices</h2>
      <p>
        If you redistribute the egg or the image, keep the license notices with it, including the
        Commons Clause text. The{" "}
        <a href={`${REPO_URL}/blob/master/LICENSE`} target="_blank" rel="noopener">LICENSE file</a>{" "}
        in the repository is the authoritative text; this page is a summary and never overrides it.
      </p>
      <p className="text-[0.85em] text-faint">
        Licensing questions: <a href="mailto:support@potenfyr.in">support@potenfyr.in</a>.
      </p>
    </DocsShell>
  );
}
