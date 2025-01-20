"use client";

import { useState, useEffect } from "react";

import { Users } from "@/sqlcgen/models";

export type UserPageInfo = {
  user: Users;
  message?: string;
}

declare global {
  interface Window {
    __SERVER_DATA__?: UserPageInfo;
  }
}

export default () => {
  const [user, setUser] = useState<Users | null>(null);
  const [message, setMessage] = useState<string>("");
  useEffect(() => {
    if (window.__SERVER_DATA__) {
      setUser(window.__SERVER_DATA__.user);
      setMessage(window.__SERVER_DATA__.message || "No Message");
    } else {
      setUser({
        id: 0,
        username: "No SSG Name",
        updatedAt: "",
        createdAt: "",
      });
    }
  }, []);
  return (
    <>
      {user !== null ? (
        <h1>User Page for User with ID: {user.id}, Name: {user.username}, Message: {message}</h1>
      ) : (
        <h1>Loading...</h1>
      )}
    </>
  )
}
