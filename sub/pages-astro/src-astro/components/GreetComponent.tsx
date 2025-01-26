import * as React from 'react';
import { useState, useEffect } from 'react';

import { hc } from 'hono/client'
import type { AppType } from '../functions/api/[[all]]';
// import type { AppType as AppTypeRespond } from '../functions/api/respond';

const client = hc<AppType>('http://localhost:8788/')
// const clientSub = hc<AppTypeRespond>('http://localhost:8788/')

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
    <p>Name:</p>
    <input type="text" value={enteredName} onChange={handleChange} />
    <h2>{message}!</h2>
  </>;
};
