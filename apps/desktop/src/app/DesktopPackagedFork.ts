/**
 * Private-fork packaged builds are a separate Mac app from Nightly/Alpha.
 * Unpackaged `vp run dev` already uses the Dev identity via VITE_DEV_SERVER_URL.
 */
export const PACKAGED_INDEPENDENT_DEV = true;

export const FORK_PACKAGED_APP_ID = "com.t3tools.t3code.dev";

export function usesIndependentPackagedDevIdentity(isPackaged: boolean): boolean {
  return PACKAGED_INDEPENDENT_DEV && isPackaged;
}
