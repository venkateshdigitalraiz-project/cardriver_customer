import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/rating_entity.dart';
import '../../domain/usecases/submit_rating_usecase.dart';
import 'rating_event.dart';
import 'rating_state.dart';

class RatingBloc extends Bloc<RatingEvent, RatingState> {
  final SubmitRatingUseCase submitRatingUseCase;

  RatingBloc({required this.submitRatingUseCase}) : super(const RatingState()) {
    on<ChangeRatingScoreEvent>(_onChangeRatingScore);
    on<ToggleRatingTagEvent>(_onToggleRatingTag);
    on<ChangeCommentEvent>(_onChangeComment);
    on<SelectTipAmountEvent>(_onSelectTipAmount);
    on<SubmitRatingEvent>(_onSubmitRating);
  }

  void _onChangeRatingScore(
    ChangeRatingScoreEvent event,
    Emitter<RatingState> emit,
  ) {
    emit(state.copyWith(rating: event.rating));
  }

  void _onToggleRatingTag(
    ToggleRatingTagEvent event,
    Emitter<RatingState> emit,
  ) {
    final current = List<String>.from(state.selectedTags);
    if (current.contains(event.tag)) {
      current.remove(event.tag);
    } else {
      current.add(event.tag);
    }
    emit(state.copyWith(selectedTags: current));
  }

  void _onChangeComment(ChangeCommentEvent event, Emitter<RatingState> emit) {
    emit(state.copyWith(comment: event.comment));
  }

  void _onSelectTipAmount(
    SelectTipAmountEvent event,
    Emitter<RatingState> emit,
  ) {
    // If the same tip is selected again, toggle it off to 0
    final newAmount = state.tipAmount == event.tipAmount
        ? 0.0
        : event.tipAmount;
    emit(state.copyWith(tipAmount: newAmount));
  }

  Future<void> _onSubmitRating(
    SubmitRatingEvent event,
    Emitter<RatingState> emit,
  ) async {
    emit(
      state.copyWith(
        status: RatingSubmissionStatus.loading,
        errorMessage: null,
      ),
    );

    try {
      final entity = RatingEntity(
        bookingId: event.bookingId,
        rating: state.rating,
        tags: state.selectedTags,
        comment: state.comment,
        tipAmount: state.tipAmount,
        driverId: event.driverId,
        driverName: event.driverName,
      );

      final success = await submitRatingUseCase(entity);
      if (success) {
        emit(state.copyWith(status: RatingSubmissionStatus.success));
      } else {
        emit(
          state.copyWith(
            status: RatingSubmissionStatus.failure,
            errorMessage: 'Failed to submit rating. Please try again.',
          ),
        );
      }
    } on Failure catch (failure) {
      emit(
        state.copyWith(
          status: RatingSubmissionStatus.failure,
          errorMessage: failure.message,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: RatingSubmissionStatus.failure,
          errorMessage: e.toString().replaceFirst('Exception: ', ''),
        ),
      );
    }
  }
}
