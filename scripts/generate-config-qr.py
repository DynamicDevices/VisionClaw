#!/usr/bin/env python3
"""
Generate QR codes for VisionClaw configuration.
Usage:
  ./scripts/generate-config-qr.py                    # Interactive mode
  ./scripts/generate-config-qr.py --key YOUR_KEY     # Quick API key QR
  ./scripts/generate-config-qr.py --json config.json # From JSON file
"""

import argparse
import json
import sys
import os

try:
    import qrcode
except ImportError:
    print("Error: qrcode module not found.")
    print("Install with: pip3 install qrcode pillow")
    sys.exit(1)


def generate_qr(data, output_file="visionclaw_config.png"):
    """Generate QR code from data."""
    qr = qrcode.QRCode(
        version=1,
        error_correction=qrcode.constants.ERROR_CORRECT_L,
        box_size=10,
        border=4,
    )
    qr.add_data(data)
    qr.make(fit=True)

    img = qr.make_image(fill_color="black", back_color="white")
    img.save(output_file)
    print(f"✅ QR code saved to: {output_file}")
    
    # Show security warning
    print("\n⚠️  Security Warning:")
    print("   This QR code contains sensitive API keys.")
    print("   Store securely and delete after scanning.")


def interactive_mode():
    """Interactive configuration builder."""
    print("═══════════════════════════════════════════════")
    print("   VisionClaw QR Code Configuration Generator")
    print("═══════════════════════════════════════════════\n")
    
    config = {}
    
    # Gemini API Key
    print("🤖 Gemini API Configuration")
    key = input("   Gemini API Key (required): ").strip()
    if not key:
        print("Error: Gemini API key is required.")
        sys.exit(1)
    config["geminiAPIKey"] = key
    
    # Optional: System prompt
    prompt = input("   Custom System Prompt (optional, press Enter to skip): ").strip()
    if prompt:
        config["geminiSystemPrompt"] = prompt
    
    # Optional: OpenClaw
    print("\n🦅 OpenClaw Configuration (optional)")
    host = input("   Host (e.g., http://192.168.1.100, press Enter to skip): ").strip()
    if host:
        config["openClawHost"] = host
        
        port = input("   Port (default 18789): ").strip()
        config["openClawPort"] = int(port) if port else 18789
        
        hook = input("   Hook Token: ").strip()
        if hook:
            config["openClawHookToken"] = hook
        
        gateway = input("   Gateway Token: ").strip()
        if gateway:
            config["openClawGatewayToken"] = gateway
    
    # Optional: WebRTC
    print("\n📡 WebRTC Configuration (optional)")
    webrtc = input("   Signaling URL (e.g., wss://server.com, press Enter to skip): ").strip()
    if webrtc:
        config["webrtcSignalingURL"] = webrtc
    
    # Generate QR code
    print("\n📦 Generating QR code...")
    data = json.dumps(config, indent=2)
    print(f"\nConfiguration:\n{data}\n")
    
    output = input("Output filename (default: visionclaw_config.png): ").strip()
    if not output:
        output = "visionclaw_config.png"
    
    generate_qr(data, output)


def main():
    parser = argparse.ArgumentParser(
        description="Generate QR codes for VisionClaw configuration"
    )
    parser.add_argument(
        "--key",
        help="Quick mode: Just generate QR for API key",
        metavar="API_KEY"
    )
    parser.add_argument(
        "--json",
        help="Generate QR from JSON file",
        metavar="FILE"
    )
    parser.add_argument(
        "-o", "--output",
        help="Output filename (default: visionclaw_config.png)",
        default="visionclaw_config.png"
    )
    
    args = parser.parse_args()
    
    if args.key:
        # Quick mode - just API key
        print(f"Generating QR code for API key...")
        generate_qr(args.key, args.output)
    elif args.json:
        # Load from JSON file
        if not os.path.exists(args.json):
            print(f"Error: File not found: {args.json}")
            sys.exit(1)
        
        with open(args.json, 'r') as f:
            config = json.load(f)
        
        data = json.dumps(config)
        print(f"Generating QR code from {args.json}...")
        generate_qr(data, args.output)
    else:
        # Interactive mode
        interactive_mode()


if __name__ == "__main__":
    main()
