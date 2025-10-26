"use client";

import { motion } from "framer-motion";
import {
  Download,
  Copy,
  CheckCircle,
  ArrowRight,
  Sparkles,
  Rocket,
  BookOpen,
} from "lucide-react";
import { useState, useEffect } from "react";
import useSWR from "swr";
const fetcher = (url: string) => fetch(url).then((res) => res.json());

export default function Hero({
  glowVariants,
}: {
  glowVariants: import("framer-motion").Variants;
}) {
  const [copiedCommand, setCopiedCommand] = useState<string>("");
  const [isClient, setIsClient] = useState(false);
  const [selectedOS, setSelectedOS] = useState<'unix' | 'windows'>('unix');
  
  const installCommands = {
    unix: "curl -s https://lazycli.xyz/install.sh | bash",
    windows: "iwr -useb https://lazycli.xyz/install.ps1 | iex"
  };
  
  const installCommand = installCommands[selectedOS];
  
  useEffect(() => {
    setIsClient(true);
  }, []);

  const copyToClipboard = (text: string) => {
    navigator.clipboard.writeText(text);
    setCopiedCommand(text);
    setTimeout(() => setCopiedCommand(""), 2000); // reset after 2 seconds
  };

  const floatingVariants = {
    initial: { y: 0 },
    animate: {
      y: [-10, 10, -10],
    },
  };

  const { data } = useSWR(
    `${process.env.NEXT_PUBLIC_LIVE_URL}/api/stars`,
    fetcher,
    {
      refreshInterval: 60000,
    }
  );

  return (
    <>
      <section className="pt-24 pb-16 relative overflow-x-hidden">
        {/* Animated Background */}
        <div className="absolute inset-0 overflow-hidden">
          {/* Gradient Background */}
          <div className="absolute inset-0 bg-gradient-to-br from-slate-900 via-blue-900/20 to-purple-900/20" />

          {/* Grid Pattern */}
          <div className='absolute inset-0 bg-[url(&apos;data:image/svg+xml,%3Csvg width="60" height="60" viewBox="0 0 60 60" xmlns="http://www.w3.org/2000/svg"%3E%3Cg fill="none" fill-rule="evenodd"%3E%3Cg fill="%23334155" fill-opacity="0.1"%3E%3Ccircle cx="3" cy="3" r="1"/%3E%3C/g%3E%3C/g%3E%3C/svg%3E&apos;)] opacity-40' />

          {/* Floating Elements - Only render on client side */}
          {isClient &&
            [...Array(15)].map((_, i) => {
              // Generate deterministic positions using index instead of random
              const left = 10 + ((i * 4.5) % 80); // Distribute evenly across 10-90%
              const top = 15 + ((i * 4.2) % 70); // Distribute evenly across 15-85%

              return (
                <motion.div
                  key={i}
                  className="absolute w-1 h-1 bg-cyan-400 rounded-full"
                  style={{
                    left: `${left}%`,
                    top: `${top}%`,
                  } as React.CSSProperties}
                  variants={floatingVariants}
                  initial="initial"
                  animate="animate"
                  transition={{
                    delay: i * 0.2, // Deterministic delay based on index
                    duration: 3 + (i % 4), // Deterministic duration based on index
                    repeat: Infinity,
                    ease: [0.42, 0, 0.58, 1],
                  }}
                />
              );
            })}

          {/* Large Glowing Orbs - Only render on client side */}
          {isClient && (
            <>
              <motion.div
                className="absolute w-24 h-24 sm:w-32 sm:h-32 bg-gradient-to-r from-cyan-400/10 to-blue-400/10 rounded-full blur-3xl"
                style={{
                  top: "20%",
                  left: "15%",
                } as React.CSSProperties}
                variants={glowVariants}
                initial="initial"
                animate="animate"
              />
              <motion.div
                className="absolute w-28 h-28 sm:w-40 sm:h-40 bg-gradient-to-r from-purple-400/10 to-pink-400/10 rounded-full blur-3xl"
                style={{
                  bottom: "20%",
                  right: "15%",
                } as React.CSSProperties}
                variants={glowVariants}
                initial="initial"
                animate="animate"
                transition={{ delay: 2 }}
              />
            </>
          )}
        </div>

        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 text-center relative z-10">
          <motion.div
            initial={{ opacity: 0, y: 50 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.8 }}
            className="mb-8"
          >
            <motion.div
              initial={{ scale: 0 }}
              animate={{ scale: 1 }}
              transition={{ delay: 0.2, type: "spring", stiffness: 200 }}
              className="inline-flex items-center px-4 py-2 bg-gradient-to-r from-cyan-500/10 to-blue-500/10 border border-cyan-500/20 rounded-full mb-6"
            >
              <Sparkles className="w-4 h-4 text-cyan-400 mr-2" />
              <span className="text-cyan-400 text-sm font-medium">
                The Future of CLI Automation
              </span>
            </motion.div>

            <h1 className="text-4xl md:text-6xl lg:text-7xl font-bold mb-6">
              <span className="bg-gradient-to-r from-white via-cyan-100 to-white bg-clip-text text-transparent">
                Automate Your
              </span>
              <motion.span
                initial={{ opacity: 0, x: -50 }}
                animate={{ opacity: 1, x: 0 }}
                transition={{ delay: 0.5, duration: 0.8 }}
                className="block bg-gradient-to-r from-cyan-400 via-blue-400 to-purple-400 bg-clip-text text-transparent"
              >
                Development Workflow
              </motion.span>
            </h1>
          </motion.div>

          <motion.p
            initial={{ opacity: 0, y: 30 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: 0.3, duration: 0.8 }}
            className="text-xl md:text-2xl text-slate-300 mb-12 max-w-4xl mx-auto leading-relaxed"
          >
            LazyCLI is a powerful CLI tool that streamlines GitHub automation,
            project scaffolding, and development workflows. Build faster, deploy
            smarter, code better.
          </motion.p>

          {/* Install Command */}
          <motion.div
            initial={{ opacity: 0, scale: 0.9 }}
            animate={{ opacity: 1, scale: 1 }}
            transition={{ delay: 0.6, duration: 0.8 }}
            className="bg-slate-800/50 backdrop-blur-xl border border-slate-700/50 rounded-2xl p-6 max-w-3xl mx-auto mb-12"
          >
            {/* OS Selector */}
            <div className="flex items-center justify-center mb-6">
              <div className="bg-slate-700/50 rounded-lg p-1 flex">
                <button
                  onClick={() => setSelectedOS('unix')}
                  className={`px-4 py-2 rounded-md text-sm font-medium transition-all ${
                    selectedOS === 'unix'
                      ? 'bg-cyan-500 text-white'
                      : 'text-slate-400 hover:text-white'
                  }`}
                >
                  Unix/Linux/macOS
                </button>
                <button
                  onClick={() => setSelectedOS('windows')}
                  className={`px-4 py-2 rounded-md text-sm font-medium transition-all ${
                    selectedOS === 'windows'
                      ? 'bg-cyan-500 text-white'
                      : 'text-slate-400 hover:text-white'
                  }`}
                >
                  Windows
                </button>
              </div>
            </div>
            
            {/* Command Display */}
            <div className="bg-slate-900/50 rounded-lg p-4 border border-slate-700/30">
              <div className="flex items-center justify-between mb-3">
                <span className="text-slate-400 text-sm flex items-center">
                  <Download className="w-4 h-4 mr-2" />
                  {selectedOS === 'unix' ? 'Bash' : 'PowerShell'}
                </span>
                <button
                  onClick={() => copyToClipboard(installCommand)}
                  className="text-cyan-400 hover:text-cyan-300 text-sm flex items-center px-3 py-1 bg-cyan-400/10 rounded-md border border-cyan-400/20 transition-colors"
                >
                  {copiedCommand === installCommand ? (
                    <>
                      <CheckCircle className="w-4 h-4 mr-1" />
                      Copied!
                    </>
                  ) : (
                    <>
                      <Copy className="w-4 h-4 mr-1" />
                      Copy
                    </>
                  )}
                </button>
              </div>
              <code className="text-cyan-400 text-lg font-mono block break-all">
                $ {installCommand}
              </code>
            </div>
          </motion.div>

          <motion.div
            initial={{ opacity: 0, y: 30 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: 0.9, duration: 0.8 }}
            className="flex flex-col sm:flex-row gap-4 justify-center"
          >
            <motion.a
              whileHover={{ scale: 1.05, y: -2 }}
              whileTap={{ scale: 0.95 }}
              href="#features"
              className="bg-gradient-to-r from-cyan-500 to-blue-500 text-white px-8 py-4 rounded-xl hover:shadow-lg hover:shadow-cyan-500/25 transition-all flex items-center justify-center group"
            >
              <Rocket className="w-5 h-5 mr-2 group-hover:animate-pulse" />
              Explore Features
              <ArrowRight className="w-5 h-5 ml-2 group-hover:translate-x-1 transition-transform" />
            </motion.a>
            <motion.a
              whileHover={{ scale: 1.05, y: -2 }}
              whileTap={{ scale: 0.95 }}
              href="#installation"
              className="border-2 border-slate-600 text-slate-300 px-8 py-4 rounded-xl hover:bg-slate-800 hover:border-cyan-400 transition-all flex items-center justify-center group"
            >
              <BookOpen className="w-5 h-5 mr-2" />
              Installation Guide
            </motion.a>
          </motion.div>

          {/* Stats */}
          <motion.div
            initial={{ opacity: 0, y: 30 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: 1.2, duration: 0.8 }}
            className="mt-16 grid grid-cols-1 md:grid-cols-3 gap-8 max-w-3xl mx-auto"
          >
            {[
              { label: "Commands Available", value: "10+" },
              { label: "Projects Scaffolded", value: "50K+" },
              {
                label: "GitHub Stars",
                value: (data?.stars || 0).toLocaleString(),
              },
            ].map((stat) => (
              <motion.div
                key={stat.label}
                whileHover={{ scale: 1.05 }}
                className="text-center"
              >
                <div className="text-2xl md:text-3xl font-bold bg-gradient-to-r from-cyan-400 to-blue-400 bg-clip-text text-transparent">
                  {stat.value}
                </div>
                <div className="text-slate-400 text-sm">{stat.label}</div>
              </motion.div>
            ))}
          </motion.div>

          {/* Product Hunt Badge */}
          <motion.div
            initial={{ opacity: 0, y: 30 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: 1.5, duration: 0.8 }}
            className="mt-12 flex justify-center"
          >
            <motion.a
              href="https://www.producthunt.com/products/lazycli?embed=true&utm_source=badge-featured&utm_medium=badge&utm_source=badge-lazycli"
              target="_blank"
              rel="noopener noreferrer"
              whileHover={{ scale: 1.05, y: -2 }}
              whileTap={{ scale: 0.95 }}
              className="group bg-slate-800/50 backdrop-blur-xl border border-slate-700 hover:border-cyan-400/50 rounded-xl px-6 py-4 flex items-center space-x-4 transition-all duration-300 hover:shadow-lg hover:shadow-cyan-500/10"
            >
              <div className="flex items-center space-x-4">
                {/* Product Hunt Logo */}
                <div className="w-8 h-8 bg-gradient-to-r from-cyan-400 to-blue-500 rounded-full flex items-center justify-center group-hover:from-cyan-300 group-hover:to-blue-400 transition-all duration-300">
                  <p className="text-white text-lg font-bold">P</p>
                </div>

                {/* Badge Content */}
                <div className="flex flex-col">
                  <div className="flex items-center space-x-2">
                    <span className="text-sm font-medium bg-gradient-to-r from-cyan-400 to-blue-400 bg-clip-text text-transparent">
                      FIND US ON
                    </span>
                    {/* <span className="text-xs bg-gradient-to-r from-cyan-400 to-blue-500 text-white px-2 py-0.5 rounded-full font-medium group-hover:from-cyan-300 group-hover:to-blue-400 transition-all duration-300">
                      #1
                    </span> */}
                  </div>
                  <span className="text-lg font-bold bg-gradient-to-r from-white to-slate-200 bg-clip-text text-transparent group-hover:from-cyan-300 group-hover:to-blue-300 transition-all duration-300">
                    Product Hunt
                  </span>
                </div>
              </div>
            </motion.a>
          </motion.div>
        </div>
      </section>
    </>
  );
}
