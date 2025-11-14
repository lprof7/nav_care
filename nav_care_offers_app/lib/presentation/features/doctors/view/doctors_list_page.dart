import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:nav_care_offers_app/core/responses/failure.dart';
import 'package:nav_care_offers_app/presentation/features/doctors/viewmodel/doctors_cubit.dart';
import 'package:nav_care_offers_app/presentation/features/doctors/viewmodel/doctors_state.dart';
import 'package:nav_care_offers_app/presentation/shared/ui/atoms/app_button.dart';
import 'package:nav_care_offers_app/presentation/shared/ui/molecules/hospital_card.dart'; // Reusing HospitalCard for doctor display

class DoctorsListPage extends StatefulWidget {
  final String hospitalId;

  const DoctorsListPage({super.key, required this.hospitalId});

  @override
  State<DoctorsListPage> createState() => _DoctorsListPageState();
}

class _DoctorsListPageState extends State<DoctorsListPage> {
  @override
  void initState() {
    super.initState();
    context.read<DoctorsCubit>().getHospitalDoctors(widget.hospitalId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('doctors_list_title'.tr()),
      ),
      body: BlocBuilder<DoctorsCubit, DoctorsState>(
        builder: (context, state) {
          return state.when(
            initial: () => const Center(child: CircularProgressIndicator()),
            loading: () => const Center(child: CircularProgressIndicator()),
            success: (doctorList) {
              if (doctorList.data.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('no_doctors_available'.tr()),
                      const SizedBox(height: 16),
                      AppButton(
                        onPressed: () {
                          // TODO: Navigate to add doctor page
                        },
                        text: 'add_doctor'.tr(),
                      ),
                    ],
                  ),
                );
              }
              return ListView.builder(
                itemCount: doctorList.data.length,
                itemBuilder: (context, index) {
                  final doctor = doctorList.data[index];
                  return HospitalCard( // Reusing HospitalCard for doctor display
                    title: doctor.name,
                    facilityLabel: 'doctor'.tr(), // Placeholder
                    onTap: () {
                      // TODO: Navigate to doctor detail page
                    },
                  );
                },
              );
            },
            failure: (failure) {
              return Center(
                child: Text('error_fetching_doctors'.tr(args: [failure.message])),
              );
            },
          );
        },
      ),
    );
  }
}