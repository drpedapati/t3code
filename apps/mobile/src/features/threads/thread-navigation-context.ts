import { createContext, use, useEffect } from "react";

import type { ThreadNavigationListItem } from "./thread-navigation";

export const ThreadNavigationRegistrationContext = createContext<
  (items: ReadonlyArray<ThreadNavigationListItem>) => () => void
>(() => () => undefined);

/** Keep the last rendered sequence while the compact list is behind the thread route. */
export function useRegisterThreadNavigationItems(items: ReadonlyArray<ThreadNavigationListItem>) {
  const register = use(ThreadNavigationRegistrationContext);
  // oxlint-disable-next-line t3code/react-effect-budget -- Registers the committed list with the navigation owner; passive cleanup survives native screen freezing.
  useEffect(() => register(items), [items, register]);
}
