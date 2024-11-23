"use client";

import { useState, useEffect } from "react";

import { Users } from "@/sqlcgen/models";

declare global {
  interface Window {
    __SERVER_DATA__?: Users;
  }
}

export default () => {
  const [user, setUser] = useState<Users | null>(null);
  useEffect(() => {
    setUser(window.__SERVER_DATA__?? {
      id: 0,
      username: "No SSG Name",
      updatedAt: "",
      createdAt: "",
   });
  }, []);
  return (
    <>
      {user !== null ? (
        <h1>User Page for User with ID: {user.id}, Name: {user.username}</h1>
      ) : (
        <h1>Loading...</h1>
      )}
    </>
  )
}
