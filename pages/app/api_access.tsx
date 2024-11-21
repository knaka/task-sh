"use client";

import { useState } from "react";
import { useEffect } from "react";

import { hc } from "hono/client";
import { AppType } from "../worker/api/_all";

const apiEndpointBase = process.env.NEXT_PUBLIC_PAGES_DEV_PORT && `http://127.0.0.1:${process.env.NEXT_PUBLIC_PAGES_DEV_PORT}/` || "/";

const client = hc<AppType>(apiEndpointBase);

console.log("apiEndpointBase", apiEndpointBase);

export const ApiAccess = () => {
  const [message, setMessage] = useState("Loading...");

  useEffect(() => {
    (async () => {
      // const response = await fetch(`${apiEndpointBase}/hello`);
      // const data: any = await response.json();
      // setMessage(data.message);

      // const response2 = await client.api.hello.$get();
      const response2 = await client.api.hello.$get({ param: {} });
      setMessage((await response2.json()).message);

      // const response3 = await client.api.world.$get();
    })();
  });
  return (<div>
    {message}
  </div>);
};
