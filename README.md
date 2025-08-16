# WD1793 Floppy Disk Controller Hardware FPGA Emulator

### Project Description  

This project is based on the **VG93 (FDC1793/WD1793) emulator core for FPGA** originally developed by [IanPo](https://github.com/IanPo) and later refactored by [andykarpov](https://github.com/andykarpov) for the **Karabas-Go** project.  

For this implementation:  
- All Beta Disk–related components were removed, leaving only the VG93 (FDC1793/WD1793) itself.  
- Several additional internal signals were routed to the VG pins, which makes the source code slightly different from the original, though not significantly.  

### Hardware & Firmware Versions  

The project provides three PCB versions, each with a corresponding FPGA firmware:  

- **kpro** – Board without buffers, modified v1 with repinned layout for convenience. Must be used only with 3.3v outputs!
- **v2** – Second board revision with buffers replacing level shifters. FPGA pinout differs from *kpro*.  
- **vDebug** – Debug version with several free pins exposed for firmware debugging. Pinout matches *v2*.  

### Credits  

- [IanPo](https://github.com/IanPo) – Original VG93 FPGA core for Firefly FPGA computer 
- [andykarpov](https://github.com/andykarpov) – Refactoring and integration into Karabas-Go  
- Community contributors and testers  

