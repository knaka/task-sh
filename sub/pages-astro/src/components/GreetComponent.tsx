import * as React from 'react';
import { useState, useEffect } from 'react';

export const GreetComponent = () => {
  const [name, setName] = useState('nobody');
  useEffect(() => {(async () => {
    const response = await fetch('https://api.github.com/users/octocat');
    const data = await response.json();
    setName(data.name);
  })()}, []);
  return <h2>Hello, {name}!</h2>;
};
