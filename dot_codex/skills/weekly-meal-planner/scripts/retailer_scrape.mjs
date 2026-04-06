#!/usr/bin/env node
import fs from "node:fs/promises";
import { chromium } from "playwright";

function parseArgs(argv) {
  const parsed = {};
  for (let index = 2; index < argv.length; index += 1) {
    const part = argv[index];
    if (!part.startsWith("--")) {
      continue;
    }
    const key = part.slice(2);
    const next = argv[index + 1];
    if (!next || next.startsWith("--")) {
      parsed[key] = true;
      continue;
    }
    parsed[key] = next;
    index += 1;
  }
  return parsed;
}

function clean(value) {
  return String(value ?? "").replace(/\s+/g, " ").trim();
}

function parsePrice(text) {
  const match = clean(text).match(/\$([0-9]+(?:\.[0-9]{2})?)/);
  return match ? Number.parseFloat(match[1]) : null;
}

function extractSize(text) {
  const match = clean(text).match(/(\d+(?:\.\d+)?)\s*(fl oz|oz|lb|lbs|gal|gallon|ct|count|ea|pack|pkg|bunch|slice|clove)/i);
  return match ? clean(match[0]) : "";
}

async function settled(page) {
  await page.waitForLoadState("domcontentloaded");
  await page.waitForTimeout(800);
}

async function scrapeAldi(page, query, limit) {
  await page.goto(`https://www.aldi.us/results?q=${encodeURIComponent(query)}`, {
    waitUntil: "domcontentloaded",
  });
  await settled(page);

  const actualStore = clean(
    await page
      .locator("button")
      .filter({ hasText: /Current store:/i })
      .first()
      .textContent()
      .catch(() => "")
  );

  const candidates = await page.evaluate((candidateLimit) => {
    const cleanText = (value) => String(value ?? "").replace(/\s+/g, " ").trim();
    const parsePriceValue = (value) => {
      const match = cleanText(value).match(/\$([0-9]+(?:\.[0-9]{2})?)/);
      return match ? Number.parseFloat(match[1]) : null;
    };

    const anchors = Array.from(document.querySelectorAll('main a[href^="/product/"]'));
    const seen = new Set();
    const results = [];
    for (const anchor of anchors) {
      const url = new URL(anchor.getAttribute("href"), location.origin).toString();
      if (seen.has(url)) {
        continue;
      }
      seen.add(url);

      const paragraphs = Array.from(anchor.querySelectorAll("p")).map((node) => cleanText(node.textContent)).filter(Boolean);
      const text = cleanText(anchor.textContent);
      const title = paragraphs.length >= 2 ? paragraphs[1] : paragraphs[0] || text;
      const size = paragraphs.length >= 3 ? paragraphs[2] : "";
      results.push({
        title,
        size,
        price: parsePriceValue(text),
        url,
        availability: text.includes("Add") ? "Add to cart shown" : "",
      });
      if (results.length >= candidateLimit) {
        break;
      }
    }
    return results;
  }, limit);

  return { actualStore, candidates };
}

async function scrapeWalmart(page, query, limit) {
  await page.goto(`https://www.walmart.com/search?q=${encodeURIComponent(query)}`, {
    waitUntil: "domcontentloaded",
  });
  await settled(page);

  const actualStore = clean(
    await page
      .locator("button")
      .filter({ hasText: /Pickup or delivery\?/i })
      .first()
      .textContent()
      .catch(() => "")
  );

  const candidates = await page.evaluate((candidateLimit) => {
    const cleanText = (value) => String(value ?? "").replace(/\s+/g, " ").trim();
    const parsePriceValue = (value) => {
      const text = cleanText(value);
      const current = text.match(/current price \$?([0-9]+(?:\.[0-9]{2})?)/i);
      if (current) {
        return Number.parseFloat(current[1]);
      }
      const fallback = text.match(/\$([0-9]+(?:\.[0-9]{2})?)/);
      return fallback ? Number.parseFloat(fallback[1]) : null;
    };
    const sizeFromText = (value) => {
      const match = cleanText(value).match(/(\d+(?:\.\d+)?)\s*(fl oz|oz|lb|lbs|gal|gallon|ct|count|ea|pack|pkg|bunch|slice|clove)/i);
      return match ? cleanText(match[0]) : "";
    };

    const anchors = Array.from(document.querySelectorAll('main a[href^="/ip/"]'));
    const seen = new Set();
    const results = [];
    for (const anchor of anchors) {
      const href = anchor.getAttribute("href");
      const url = new URL(href, location.origin).toString();
      if (seen.has(url)) {
        continue;
      }
      seen.add(url);

      const container =
        anchor.closest('[data-item-id]') ||
        anchor.closest('li') ||
        anchor.closest('[role="group"]') ||
        anchor.parentElement;
      const cardText = cleanText(container?.textContent || anchor.textContent);
      const title =
        cleanText(anchor.querySelector("h3")?.textContent) ||
        cleanText(container?.querySelector("h3")?.textContent) ||
        cleanText(anchor.textContent);
      const availabilityMatches = cardText.match(/Pickup available|Delivery available|Shipping available/gi) || [];

      results.push({
        title,
        size: sizeFromText(`${title} ${cardText}`),
        price: parsePriceValue(cardText),
        url,
        availability: availabilityMatches.join(", "),
      });
      if (results.length >= candidateLimit) {
        break;
      }
    }
    return results;
  }, limit);

  return { actualStore, candidates };
}

async function scrapeRetailer(page, retailer, query, limit) {
  if (retailer === "aldi") {
    return scrapeAldi(page, query, limit);
  }
  return scrapeWalmart(page, query, limit);
}

async function main() {
  const args = parseArgs(process.argv);
  if (!args.input || !args.output) {
    throw new Error("Usage: retailer_scrape.mjs --input request.json --output response.json");
  }

  const request = JSON.parse(await fs.readFile(args.input, "utf8"));
  const browser = await chromium.launch({ headless: true });
  const context = await browser.newContext({ viewport: { width: 1440, height: 2200 } });
  const page = await context.newPage();

  const response = {
    aldi: { actual_store: "", results: [] },
    walmart: { actual_store: "", results: [] },
  };

  for (const retailer of ["aldi", "walmart"]) {
    for (const item of request.queries || []) {
      const query = clean(item.query);
      if (!query) {
        continue;
      }
      const scraped = await scrapeRetailer(page, retailer, query, item.limit || 5);
      response[retailer].actual_store = scraped.actualStore || response[retailer].actual_store;
      response[retailer].results.push({
        grocery_item_id: item.grocery_item_id,
        query,
        actual_store: scraped.actualStore,
        candidates: scraped.candidates,
      });
    }
  }

  await context.close();
  await browser.close();
  await fs.writeFile(args.output, JSON.stringify(response, null, 2));
}

main().catch((error) => {
  console.error(error instanceof Error ? error.stack || error.message : String(error));
  process.exitCode = 1;
});
