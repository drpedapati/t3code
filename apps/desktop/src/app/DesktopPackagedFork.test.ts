import { describe, expect, it } from "@effect/vitest";
import { resolveRemoteT3CliPackageSpec } from "@t3tools/ssh/command";
import { remoteCliVersionForDesktop } from "./DesktopPackagedFork.ts";

describe("private desktop SSH package", () => {
  it("installs the matching public server instead of the unpublished Dev version", () => {
    expect(
      resolveRemoteT3CliPackageSpec({
        appVersion: remoteCliVersionForDesktop("0.0.39-dev.20260905.2", true),
        updateChannel: "latest",
        isDevelopment: false,
      }),
    ).toBe("t3@0.0.39-nightly.20260905.1286");
  });

  it("preserves unpackaged development version handling", () => {
    expect(remoteCliVersionForDesktop("0.0.0", false)).toBe("0.0.0");
  });
});
