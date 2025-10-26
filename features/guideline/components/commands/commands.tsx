import { motion } from "framer-motion";
import {
  Github,
  Zap,
  Code2,
  Rocket,
  Smartphone,
  Snowflake,
} from "lucide-react";
export default function Commands() {
  const supportedCommands = [
    {
      icon: Github,
      command: "github",
      description:
        "Complete GitHub workflow automation with repository management",
      example: 'lazy github pr main "Add new feature"',
    },
    {
      icon: Code2,
      command: "node-js",
      description:
        "Initialize Node.js projects with TypeScript and interactive package selection",
      example: "lazy node-js init",
    },
    {
      icon: Rocket,
      command: "next-js",
      description:
        "Initialize Next.js applications with TypeScript, Tailwind, and modern tooling",
      example: "lazy next-js init",
    },
    {
      icon: Zap,
      command: "vite-js",
      description:
        "Bootstrap Vite projects with framework selection and Tailwind/DaisyUI integration",
      example: "lazy vite-js init",
    },
    {
      icon: Smartphone,
      command: "react-native",
      description:
        "Initialize cross-platform React Native mobile apps with Expo or CLI",
      example: "lazy react-native init",
    },
    {
      icon: Snowflake,
      command: "django",
      description:
        "Initialize Django projects with pre-configured structure for static, templates, and media",
      example: "lazy django init myproject",
    },
  ];

  return (
    <>
      {" "}
      <motion.section
        className="mb-20"
        variants={{
          hidden: { y: 30, opacity: 0 },
          visible: {
            y: 0,
            opacity: 1,
            transition: {
              type: "tween",
              duration: 0.6,
              ease: "easeOut",
            },
          },
        }}
      >
        <div className="text-center mb-12">
          <h2 className="text-3xl font-bold bg-gradient-to-r from-cyan-400 to-blue-400 bg-clip-text text-transparent mb-4">
            Supported Commands
          </h2>
          <p className="text-lg text-slate-300 max-w-2xl mx-auto">
            Currently available automation commands with more coming soon.
          </p>
        </div>

        <div className="grid md:grid-cols-2 gap-6">
          {supportedCommands.map((cmd, index) => (
            <motion.div
              key={index}
              className="bg-slate-800/50 backdrop-blur-xl border border-slate-700 p-6 rounded-xl hover:bg-slate-800/70 transition-all hover:border-cyan-400/30"
              variants={{
                hidden: { y: 30, opacity: 0 },
                visible: {
                  y: 0,
                  opacity: 1,
                  transition: {
                    type: "tween",
                    duration: 0.6,
                    ease: "easeOut",
                  },
                },
              }}
              whileHover={{ y: -2 }}
            >
              <div className="flex items-start space-x-4">
                <cmd.icon className="w-8 h-8 text-cyan-400 mt-1" />
                <div className="flex-1">
                  <h3 className="text-lg font-semibold text-white mb-2">
                    {cmd.command}
                  </h3>
                  <p className="text-slate-300 mb-3">{cmd.description}</p>
                  <code className="bg-slate-900/50 px-3 py-1 rounded text-sm text-cyan-400 font-mono">
                    {cmd.example}
                  </code>
                </div>
              </div>
            </motion.div>
          ))}
        </div>
      </motion.section>
    </>
  );
}
