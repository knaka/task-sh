// @ts-check

import { PHASE_DEVELOPMENT_SERVER } from 'next/constants.js';
 
export default (phase = "", { defaultConfig }) => {
  /**
   * @type {import('next').NextConfig}
   */
  if (phase === PHASE_DEVELOPMENT_SERVER) {
    const apiEndpointBase = process.env.NEXT_PUBLIC_PAGES_DEV_PORT && `http://127.0.0.1:${process.env.NEXT_PUBLIC_PAGES_DEV_PORT}/` || "/";
    let config = {
      ...defaultConfig,
      distDir: "build/next-dev",
      reactStrictMode: true, 
    }
    if (process.env.NEXT_PUBLIC_PAGES_DEV_PORT) {
      config["rewrites"] = async () => {
        return [
          {
            source: '/api/:path*',
            destination: `http://127.0.0.1:${process.env.NEXT_PUBLIC_PAGES_DEV_PORT}/api/:path*`,
          },
          {
            source: '/var/:path*',
            destination: `http://127.0.0.1:${process.env.NEXT_PUBLIC_PAGES_DEV_PORT}/var/:path*`,
          }
        ]
      }
    }
    return config;
  }
  return {
    ...defaultConfig,
    output: "export",
    distDir: "build/next",
    reactStrictMode: false, 
  };
};
