/**
 * Private-fork packaged builds are a separate Mac app from Nightly/Alpha.
 * Unpackaged `vp run dev` already uses the Dev identity via VITE_DEV_SERVER_URL.
 */
export const PACKAGED_INDEPENDENT_DEV = true;

export function usesIndependentPackagedDevIdentity(isPackaged: boolean): boolean {
  return PACKAGED_INDEPENDENT_DEV && isPackaged;
}

// Keep this aligned with the upstream nightly merged into this fork. Private
// desktop versions are not published to npm, but SSH installs the public CLI.
export function remoteCliVersionForDesktop(appVersion: string, isPackaged: boolean): string {
  return usesIndependentPackagedDevIdentity(isPackaged)
    ? "0.0.39-nightly.20260905.1286"
    : appVersion;
}
