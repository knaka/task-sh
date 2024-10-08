"use client";

import { useState } from "react";
import { useEffect } from "react";

const apiEndpointBase = process.env.NEXT_PUBLIC_API_PORT && `http://127.0.0.1:${process.env.NEXT_PUBLIC_API_PORT}/api` || "/api";

console.log("apiEndpointBase", apiEndpointBase);

export const ApiAccess = () => {
  const [message, setMessage] = useState("Loading...");

  useEffect(() => {
    (async () => {
      const response = await fetch(`${apiEndpointBase}/hello`);
      const data = await response.text();
      setMessage(data);
    })();
  });
  return (<div>
    {message}
  </div>);
};
