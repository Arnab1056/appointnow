# AppointNow

AppointNow is a comprehensive medical appointment management system designed to streamline healthcare services for users, doctors, hospitals, and diagnostic centers. The platform offers features such as appointment booking, telemedicine consultations, ambulance services, and subscription plans to enhance user experience and accessibility.

## Features

-  # #User Panel # #
  - Login and Registration: Users can create accounts and log in to access services.
  - Hospital-wise Doctor Appointment: Book appointments with doctors based on hospital availability.
  - Telemedicine Consultation: Premium users can consult doctors online.
  - Ambulance Booking: Book ambulances for emergencies.
  - Action Buttons:
    - Paid: Confirms payment after consultation.
    - Refund: Requests a refund.
    - Appointment Cancel: Cancels the appointment.

-  # #Doctor Panel # #
  - Doctor Registration: Doctors can register and manage their profiles.
  - Chamber Notifications: Notify hospitals about chamber schedules.

-  # Hospital Panel # #
  - Hospital Registration: Hospitals can register and manage their profiles.
  - Doctor Requests: Send requests to doctors for chamber availability.

-  # #Diagnostic Center Panel # #
  - Notify patients about report statuses:
    - Pending
    - Done
    - Delivered

-  # #Doctor’s Assistant Panel # #
  - Appointment Management:
    - View appointment lists.
    - Notify patients about the doctor’s arrival.
    - Notify patients about their position in the queue.
  - Appointment Acceptance:
    - Accept appointments and notify patients if appointments are closed for the day.

-  # #Rating System # #
  - Patients can rate:
    - Doctors after checkups.
    - Hospitals and ambulance services.

-  # #Payment System # #
  - Payments are made at the time of appointment booking.
  - Payment Actions:
    - Paid: Transfers payment to the doctor’s account after confirmation.
    - Refund: Refunds the payment to the patient.
    - Appointment Cancel: Cancels the appointment and processes refunds.
  - Automatic Payment Transfer:
    - If no action is taken within 24 hours, the payment is automatically transferred to the doctor’s account.

-  # #Messaging Platform # #
  - Premium users can chat with doctors for emergency consultations.

-  # #Subscription Plans # #
  - Basic (Free):
    - Book appointments.
    - Access doctor, hospital, diagnostic center, and ambulance information.
  - Premium (৳199/month):
    - Unlimited teleconsultations.
    - Prescription archive.
    - Chat with doctors.
  - Family (৳499/month):
    - Includes 4 members.
    - Priority appointments.

-  # #Revenue Model # #
  - 5% of each appointment payment is debited to the app’s account.

-  # #Ambulance Booking # #
  - Users can book ambulances directly from the app.

-  # #AI ChatBot # #
  - Predicts diseases based on symptoms.
  - Suggests appropriate doctors for consultation.

## Technical Details

-  # #Frontend # #
  - Developed using Flutter for cross-platform compatibility.
  - Responsive design for mobile, web, and desktop.

-  # #Backend # #
  - Firebase for authentication, database, and real-time messaging.
  - Payment gateway integration for secure transactions.

-  # #AI ChatBot # #
  - Machine learning model for disease prediction.
  - Integrated with the app for real-time suggestions.

## Future Enhancements

- Integration with wearable devices for health monitoring.
- Advanced analytics for hospitals and doctors.
- Multi-language support for wider accessibility.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
