import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/vistara_theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _recentHistory = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VistaraColors.lilacWhite,

      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  20,
                  12,
                  20,
                  28,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Settings',
                      style: GoogleFonts.poppins(
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        color: VistaraColors.plumCharcoal,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      'Manage your application preferences\n'
                          'and privacy controls.',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        height: 1.55,
                        color: VistaraColors.bodyText,
                      ),
                    ),

                    const SizedBox(height: 34),

                    _sectionLabel('PREFERENCES'),

                    const SizedBox(height: 10),

                    _buildSettingsCard(
                      children: [
                        _buildSettingRow(
                          icon: Icons.palette_outlined,
                          title: 'Theme',
                          subtitle:
                          'Customize your visual interface',
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Light Mode',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: VistaraColors.bodyText,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                Icons.chevron_right_rounded,
                                color: VistaraColors.mutedText,
                              ),
                            ],
                          ),
                          onTap: () {},
                        ),
                      ],
                    ),

                    const SizedBox(height: 28),

                    _sectionLabel('PRIVACY'),

                    const SizedBox(height: 10),

                    _buildSettingsCard(
                      children: [
                        _buildSettingRow(
                          icon: Icons.history_rounded,
                          title: 'Recent document history',
                          subtitle:
                          'Remember recently viewed items',
                          trailing: Switch.adaptive(
                            value: _recentHistory,
                            activeTrackColor:
                            VistaraColors.ochreAmber,
                            onChanged: (value) {
                              setState(() {
                                _recentHistory = value;
                              });
                            },
                          ),
                        ),

                        Divider(
                          height: 1,
                          color: VistaraColors.lavenderGray
                              .withValues(alpha: 0.22),
                        ),

                        Padding(
                          padding: const EdgeInsets.all(18),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Clear activity',
                                      style: GoogleFonts.poppins(
                                        fontSize: 15,
                                        fontWeight:
                                        FontWeight.w600,
                                        color:
                                        VistaraColors
                                            .plumCharcoal,
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      'Remove all local history records',
                                      style: GoogleFonts.poppins(
                                        fontSize: 11,
                                        color:
                                        VistaraColors.mutedText,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(width: 12),

                              OutlinedButton(
                                onPressed: _showClearDialog,
                                style:
                                OutlinedButton.styleFrom(
                                  foregroundColor:
                                  VistaraColors.plumCharcoal,
                                  side: BorderSide(
                                    color: VistaraColors
                                        .mutedText
                                        .withValues(
                                      alpha: 0.45,
                                    ),
                                  ),
                                  padding:
                                  const EdgeInsets.symmetric(
                                    horizontal: 15,
                                    vertical: 11,
                                  ),
                                  shape:
                                  RoundedRectangleBorder(
                                    borderRadius:
                                    BorderRadius.circular(
                                      22,
                                    ),
                                  ),
                                ),
                                child: Text(
                                  'Clear Recent\nDocuments',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.poppins(
                                    fontSize: 9,
                                    fontWeight:
                                    FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 28),

                    _sectionLabel('ABOUT'),

                    const SizedBox(height: 10),

                    _buildSettingsCard(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(18),
                          child: Row(
                            children: [
                              Text(
                                'Vistara',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight:
                                  FontWeight.w600,
                                  color:
                                  VistaraColors
                                      .plumCharcoal,
                                ),
                              ),

                              const Spacer(),

                              Text(
                                'v1.0',
                                style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  color:
                                  VistaraColors.mutedText,
                                ),
                              ),
                            ],
                          ),
                        ),

                        Divider(
                          height: 1,
                          color: VistaraColors.lavenderGray
                              .withValues(alpha: 0.22),
                        ),

                        InkWell(
                          onTap: _showDisclaimer,
                          child: Padding(
                            padding:
                            const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 19,
                            ),
                            child: Row(
                              children: [
                                Text(
                                  'Disclaimer',
                                  style: GoogleFonts.poppins(
                                    fontSize: 15,
                                    fontWeight:
                                    FontWeight.w500,
                                    color:
                                    VistaraColors
                                        .plumCharcoal,
                                  ),
                                ),

                                const Spacer(),

                                Icon(
                                  Icons.arrow_forward_rounded,
                                  size: 19,
                                  color:
                                  VistaraColors.mutedText,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 25),

                    Row(
                      mainAxisAlignment:
                      MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.info_outline_rounded,
                          size: 15,
                          color: VistaraColors.mutedText,
                        ),

                        const SizedBox(width: 6),

                        Flexible(
                          child: Text(
                            'AI-powered risk analysis. Not legal advice.',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              fontSize: 9,
                              color:
                              VistaraColors.mutedText,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      // IMPORTANT:
      // No bottomNavigationBar here.
      // MainNavigation owns the single navigation bar.
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        20,
        10,
        20,
        12,
      ),
      decoration: BoxDecoration(
        color: VistaraColors.lilacWhite,
        border: Border(
          bottom: BorderSide(
            color: VistaraColors.lavenderGray
                .withValues(alpha: 0.18),
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.menu_rounded,
            color: VistaraColors.plumCharcoal,
            size: 24,
          ),

          const Spacer(),

          Text(
            'VISTARA',
            style: GoogleFonts.poppins(
              fontSize: 21,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
              color: VistaraColors.ochreAmber,
            ),
          ),

          const Spacer(),

          const SizedBox(width: 24),
        ],
      ),
    );
  }

  Widget _sectionLabel(String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        fontSize: 10,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.1,
        color: VistaraColors.mutedText,
      ),
    );
  }

  Widget _buildSettingsCard({
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: VistaraColors.lavenderGray
              .withValues(alpha: 0.25),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildSettingRow({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Padding(
        padding: const EdgeInsets.all(17),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: VistaraColors.softLavender,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 21,
                color: VistaraColors.ochreAmber,
              ),
            ),

            const SizedBox(width: 13),

            Expanded(
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color:
                      VistaraColors.plumCharcoal,
                    ),
                  ),

                  const SizedBox(height: 3),

                  Text(
                    subtitle,
                    style: GoogleFonts.poppins(
                      fontSize: 10.5,
                      height: 1.4,
                      color:
                      VistaraColors.mutedText,
                    ),
                  ),
                ],
              ),
            ),

            if (trailing != null) trailing,
          ],
        ),
      ),
    );
  }

  void _showClearDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor:
          VistaraColors.lilacWhite,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            'Clear recent documents?',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: VistaraColors.plumCharcoal,
            ),
          ),
          content: Text(
            'This will remove your locally stored '
                'recent document history.',
            style: GoogleFonts.poppins(
              fontSize: 12,
              height: 1.5,
              color: VistaraColors.bodyText,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.pop(context),
              child: Text(
                'Cancel',
                style: GoogleFonts.poppins(
                  color:
                  VistaraColors.plumCharcoal,
                ),
              ),
            ),

            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor:
                VistaraColors.ochreAmber,
                foregroundColor: Colors.white,
                elevation: 0,
              ),
              child: Text(
                'Clear',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showDisclaimer() {
    showModalBottomSheet(
      context: context,
      backgroundColor:
      VistaraColors.lilacWhite,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(26),
        ),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              22,
              22,
              22,
              30,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  'Disclaimer',
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color:
                    VistaraColors.plumCharcoal,
                  ),
                ),

                const SizedBox(height: 14),

                Text(
                  'Vistara provides AI-powered educational '
                      'risk analysis, not legal advice. '
                      'AI-generated results may be incomplete '
                      'or inaccurate and should not be relied '
                      'upon as a substitute for advice from a '
                      'qualified legal professional.',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    height: 1.6,
                    color: VistaraColors.bodyText,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}