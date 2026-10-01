import { createContext, use, useEffect } from "react";

import type { ThreadNavigationListItem } from "./thread-navigation";

export const ThreadNavigationRegistrationContext = createContext<
  (items: ReadonlyArray<ThreadNavigationListItem>) => () => void
>(() => () => undefined);

/** Keep the last rendered sequence while the compact list is behind the thread route. */
export function useRegisterThreadNavigationItems(items: ReadonlyArray<ThreadNavigationListItem>) {
  const register = use(ThreadNavigationRegistrationContext);
  // Passive effects survive a frozen screen hiding its layout effects.
  useEffect(() => register(items), [items, register]);
}
