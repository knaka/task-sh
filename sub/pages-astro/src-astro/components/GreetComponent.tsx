import * as React from 'react';
import { useState, useEffect } from 'react';

import { hc } from 'hono/client';
import type { AppType } from '@src_pages/functions/api/[[all]].ts';

// const apiEndpointBase = import.meta.env.PAGES_DEV_PORT && `http://127.0.0.1:${import.meta.env.PAGES_DEV_PORT}/` || "/";
// console.log("apiEndpointBase", apiEndpointBase);
// const client = hc<AppType>(apiEndpointBase);

const client = hc<AppType>("/");

export const GreetComponent = () => {
  const [message, setMessage] = useState('No message.');
  const [enteredName, setEnteredName] = useState('Nobody');
  const [debouncedName, setDebouncedName] = useState(enteredName);
  useEffect(() => {
    const timeout = setTimeout(() => {
      setDebouncedName(enteredName);
    }, 300);
    return () => clearTimeout(timeout);
  }, [enteredName]);
  useEffect(() => {
    (async () => {
      const resp = await client.api.greet.$post({
        json: { name: debouncedName },
      });
      if (resp.ok) {
        const body = await resp.json();
        setMessage(body.message);
      }
    })();
  }, [debouncedName]);
  const handleChange = (event: React.ChangeEvent<HTMLInputElement>) => {
    setEnteredName(event.target.value);
  };
  return <>
    <p>993ce33</p>
    <p>Name:</p>
    <input type="text" value={enteredName} onChange={handleChange} />
    <h2>{message}!</h2>
  </>;
};
