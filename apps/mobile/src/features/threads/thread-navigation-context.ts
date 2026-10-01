import { createContext, use, useEffect } from "react";

import type { ThreadNavigationListItem } from "./thread-navigation";

export const ThreadNavigationRegistrationContext = createContext<
  (items: ReadonlyArray<ThreadNavigationListItem>) => void
>(() => undefined);

/** Keep the last rendered sequence while the compact list is behind the thread route. */
export function useRegisterThreadNavigationItems(
  items: ReadonlyArray<ThreadNavigationListItem>,
  active = true,
) {
  const register = use(ThreadNavigationRegistrationContext);
  // oxlint-disable-next-line t3code/no-unreasoned-state-sync -- Publishes the visible list to the navigation owner; retain it while a search result is open.
  useEffect(() => {
    if (active) register(items);
  }, [items, register, active]);
}
